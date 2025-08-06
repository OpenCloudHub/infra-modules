# modules/github/repositories.tf

# -----------------------------
# Repositories
# -----------------------------
resource "github_repository" "all" {
  for_each = var.repositories

  name         = each.key
  description  = each.value.description
  visibility   = each.value.visibility
  topics       = each.value.topics
  homepage_url = each.value.homepage_url

  # Features
  has_issues      = each.value.has_issues
  has_wiki        = each.value.has_wiki
  has_discussions = each.value.has_discussions
  has_downloads   = each.value.has_downloads
  has_projects    = each.value.has_projects
  is_template     = each.value.is_template

  # Auto-init and templates
  auto_init          = true
  gitignore_template = each.value.gitignore_template
  license_template   = each.value.visibility == "public" ? each.value.license_template : null

  # Merge settings
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = true

  # Security settings
  vulnerability_alerts = true
  archived             = false
  archive_on_destroy   = false
  # web_commit_signoff_required = var.organization_config.web_commit_signoff_required # Handled org wide

  # Template configuration
  dynamic "template" {
    for_each = each.value.template != null ? [each.value.template] : []
    content {
      owner                = template.value.owner
      repository           = template.value.repository
      include_all_branches = template.value.include_all_branches
    }
  }

  # Pages configuration (if org allows)
  dynamic "pages" {
    for_each = (each.value.pages != null && var.organization_config.members_can_create_pages) ? [each.value.pages] : []

    content {
      build_type = pages.value.build_type
      cname      = pages.value.cname

      dynamic "source" {
        for_each = pages.value.source != null ? [pages.value.source] : []
        content {
          branch = source.value.branch
          path   = source.value.path
        }
      }
    }
  }

  # Security and analysis
  dynamic "security_and_analysis" {
    for_each = local.repo_features[each.key].secret_scanning_enabled || local.repo_features[each.key].push_protection_enabled ? [1] : []

    content {
      # Skip advanced_security block entirely for public repos
      dynamic "advanced_security" {
        for_each = each.value.visibility == "private" && local.repo_features[each.key].advanced_security_enabled ? [1] : []
        content {
          status = "enabled"
        }
      }

      dynamic "secret_scanning" {
        for_each = local.repo_features[each.key].secret_scanning_enabled ? [1] : []
        content {
          status = "enabled"
        }
      }

      dynamic "secret_scanning_push_protection" {
        for_each = local.repo_features[each.key].push_protection_enabled ? [1] : []
        content {
          status = "enabled"
        }
      }
    }
  }


}

# -----------------------------
# Repository Rulesets (Free Plan)
# -----------------------------
resource "github_repository_ruleset" "default" {
  for_each = {
    for repo_key, features in local.repo_features :
    repo_key => features if features.rulesets_enabled
  }

  name        = "default-security"
  repository  = github_repository.all[each.key].name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH", "~ALL"]
      exclude = []
    }
  }

  # Admin bypass
  bypass_actors {
    actor_id    = 1
    actor_type  = "OrganizationAdmin"
    bypass_mode = "always"
  }
  bypass_actors {
    actor_id    = 5 # Repository admin role
    actor_type  = "RepositoryRole"
    bypass_mode = "pull_request"
  }

  rules {
    creation                = false
    deletion                = var.security_config.block_deletions
    update                  = false
    non_fast_forward        = var.security_config.block_force_pushes
    required_linear_history = var.security_config.require_linear_history
    required_signatures     = var.security_config.require_signed_commits

    pull_request {
      required_approving_review_count   = var.security_config.required_approving_review_count
      dismiss_stale_reviews_on_push     = var.security_config.dismiss_stale_reviews
      require_code_owner_review         = var.security_config.require_code_owner_review
      require_last_push_approval        = var.security_config.require_last_push_approval
      required_review_thread_resolution = var.security_config.required_conversation_resolution
    }

    dynamic "required_status_checks" {
      for_each = length(var.security_config.required_status_checks) > 0 ? [1] : []
      content {
        strict_required_status_checks_policy = true

        dynamic "required_check" {
          for_each = var.security_config.required_status_checks
          content {
            context        = required_check.value.context
            integration_id = required_check.value.integration_id
          }
        }
      }
    }

    dynamic "commit_message_pattern" {
      for_each = var.security_config.commit_message_pattern != null ? [var.security_config.commit_message_pattern] : []
      content {
        name     = commit_message_pattern.value.name
        operator = "matches"
        pattern  = commit_message_pattern.value.pattern
        negate   = commit_message_pattern.value.negate
      }
    }

    dynamic "branch_name_pattern" {
      for_each = var.security_config.branch_name_pattern != null ? [var.security_config.branch_name_pattern] : []
      content {
        name     = branch_name_pattern.value.name
        operator = "matches"
        pattern  = branch_name_pattern.value.pattern
        negate   = branch_name_pattern.value.negate
      }
    }
  }

  depends_on = [github_repository.all]
}


# -----------------------------
# Repository Collaborators
# -----------------------------
resource "github_repository_collaborators" "all" {
  for_each = {
    for repo_name, repo_config in var.repositories :
    repo_name => repo_config
  }

  repository = github_repository.all[each.key].name

  # Team collaborators - with conditional check for team existence
  dynamic "team" {
    for_each = each.value.team_permissions
    content {
      team_id    = github_team.all[team.key].id # contains(keys(github_team.all), team.key) ? github_team.all[team.key].slug : team.key
      permission = team.value
    }
  }
}

# -----------------------------
# Repository Environments
# -----------------------------
resource "github_repository_environment" "all" {
  for_each = {
    for item in flatten([
      for repo_name, repo_config in var.repositories : [
        for env_name, env_config in try(repo_config.environments, {}) : {
          key         = "${repo_name}:${env_name}"
          repository  = repo_name
          environment = env_name
          config      = env_config
        }
      ]
    ]) : item.key => item
  }

  repository  = github_repository.all[each.value.repository].name
  environment = each.value.environment

  # Wait timer before deployment
  wait_timer = try(each.value.config.wait_timer, 0)

  # Require protection for this environment
  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }

  # Required reviewers
  reviewers {
    users = try(each.value.config.required_reviewers.users, [])
    teams = try([
      for team in each.value.config.required_reviewers.teams :
      github_team.all[team].id
    ], [])
  }

  depends_on = [github_repository.all, github_team.all]
}


# -----------------------------
# Repository Milestones
# -----------------------------
resource "github_repository_milestone" "all" {
  for_each = length(var.common_milestones) > 0 && length(var.repositories) > 0 ? {
    for item in flatten([
      for repo_name, _ in var.repositories : [
        for milestone in var.common_milestones : {
          key         = "${repo_name}:${milestone.title}"
          repository  = repo_name
          title       = milestone.title
          description = try(milestone.description, "")
          due_date    = try(milestone.due_date, null)
          state       = try(milestone.state, "open")
        }
      ]
    ]) : item.key => item
  } : {}

  owner       = var.github_owner
  repository  = github_repository.all[each.value.repository].name
  title       = each.value.title
  description = each.value.description
  due_date    = each.value.due_date
  state       = each.value.state
}

# -----------------------------
# Repository Labels
# -----------------------------
resource "github_issue_labels" "all" {
  for_each = var.repositories

  repository = github_repository.all[each.key].name

  dynamic "label" {
    for_each = var.common_labels
    content {
      name        = label.value.name
      color       = label.value.color
      description = label.value.description
    }
  }
}


