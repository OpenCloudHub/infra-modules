# modules/github/outputs.tf

# -----------------------------
# Organization Outputs
# -----------------------------
output "organization_name" {
  description = "GitHub organization name"
  value       = var.github_owner
}

output "organization_config" {
  description = "Organization configuration applied"
  value = {
    billing_email      = var.organization_config.billing_email
    default_permission = var.organization_config.default_repository_permission
    security_features = {
      commit_signoff_required = var.organization_config.web_commit_signoff_required
      advanced_security       = var.organization_config.advanced_security_enabled_for_new_repositories
      secret_scanning         = var.organization_config.secret_scanning_enabled_for_new_repositories
      dependabot_alerts       = var.organization_config.dependabot_alerts_enabled_for_new_repositories
    }
  }
}

# -----------------------------
# Teams Outputs
# -----------------------------
output "teams" {
  description = "Created GitHub teams"
  value = {
    for name, team in github_team.all : name => {
      id          = team.id
      slug        = team.slug
      description = team.description
      privacy     = team.privacy
      members_count = length([
        for membership in local.team_memberships : membership
        if membership.team == name
      ])
    }
  }
}

output "team_ids" {
  description = "Map of team names to team IDs (for repository permissions)"
  value = {
    for name, team in github_team.all : name => team.id
  }
}

output "team_slugs" {
  description = "Map of team names to team slugs"
  value = {
    for name, team in github_team.all : name => team.slug
  }
}

# -----------------------------
# Repository Outputs
# -----------------------------
output "repositories" {
  description = "Created GitHub repositories"
  value = {
    for name, repo in github_repository.all : name => {
      id               = repo.id
      repo_id          = repo.repo_id
      node_id          = repo.node_id
      name             = repo.name
      full_name        = repo.full_name
      html_url         = repo.html_url
      http_clone_url   = repo.http_clone_url
      ssh_clone_url    = repo.ssh_clone_url
      git_clone_url    = repo.git_clone_url
      svn_url          = repo.svn_url
      visibility       = repo.visibility
      topics           = repo.topics
      default_branch   = repo.default_branch
      primary_language = repo.primary_language
    }
  }
}

output "repository_urls" {
  description = "Map of repository names to clone URLs"
  value = {
    for name, repo in github_repository.all : name => {
      https = repo.http_clone_url
      ssh   = repo.ssh_clone_url
      git   = repo.git_clone_url
    }
  }
}

# -----------------------------
# Members Outputs
# -----------------------------
output "organization_members" {
  description = "Organization members"
  value = {
    for username, member in github_membership.all : username => {
      username = member.username
      role     = member.role
    }
  }
}

# -----------------------------
# Security Outputs
# -----------------------------
output "security_summary" {
  description = "Summary of applied security configurations"
  value = {
    rulesets_created = length(github_repository_ruleset.default)
    repositories_with_rulesets = [
      for repo_name, features in local.repo_features : repo_name
      if features.rulesets_enabled
    ]
    common_labels_applied     = length(var.common_labels) > 0
    common_milestones_applied = length(var.common_milestones) > 0
  }
}
