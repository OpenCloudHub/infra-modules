# modules/github/variables.tf

# -----------------------------
# Core Configuration
# -----------------------------
variable "github_owner" {
  description = "GitHub organization name"
  type        = string
}

variable "github_token" {
  description = "GitHub personal access token with admin:org and repo permissions"
  type        = string
  sensitive   = true
}

# -----------------------------
# Organization Configuration
# -----------------------------
variable "organization_config" {
  description = "Organization-wide configurations"
  type = object({
    billing_email                                                = string
    company                                                      = optional(string, "")
    blog                                                         = optional(string, "")
    email                                                        = optional(string, "")
    location                                                     = optional(string, "")
    description                                                  = optional(string, "")
    has_organization_projects                                    = optional(bool, false)
    has_repository_projects                                      = optional(bool, false)
    default_repository_permission                                = optional(string, "write")
    members_can_create_repositories                              = optional(bool, false)
    members_can_create_public_repositories                       = optional(bool, false)
    members_can_create_private_repositories                      = optional(bool, false)
    members_can_create_pages                                     = optional(bool, false)
    members_can_fork_private_repositories                        = optional(bool, false)
    web_commit_signoff_required                                  = optional(bool, true)
    advanced_security_enabled_for_new_repositories               = optional(bool, true)
    dependabot_alerts_enabled_for_new_repositories               = optional(bool, true)
    dependabot_security_updates_enabled_for_new_repositories     = optional(bool, true)
    dependency_graph_enabled_for_new_repositories                = optional(bool, true)
    secret_scanning_enabled_for_new_repositories                 = optional(bool, true)
    secret_scanning_push_protection_enabled_for_new_repositories = optional(bool, true)
  })
}

variable "security_manager_team_slug" {
  description = "GitHub team slug for security manager (could be admin)"
  type        = string
}

# -----------------------------
# Membership
# -----------------------------
variable "organization_members" {
  description = "Organization members to create"
  type = map(object({
    username = string
    role     = string
  }))
  default = {}
}

# -----------------------------
# Teams
# -----------------------------
variable "teams" {
  description = "GitHub teams configuration"
  type = map(object({
    description = string
    privacy     = optional(string, "closed")
    members = list(object({
      username = string
      role     = optional(string, "member")
    }))
  }))
  default = {}
}

# -----------------------------
# Repositories
# -----------------------------
variable "repositories" {
  description = "Repository configurations"
  type = map(object({
    description     = string
    visibility      = optional(string, "public")
    topics          = optional(list(string), [])
    homepage_url    = optional(string, "")
    has_issues      = optional(bool, true)
    has_wiki        = optional(bool, false)
    has_discussions = optional(bool, false)
    has_downloads   = optional(bool, true)
    has_projects    = optional(bool, false)
    is_template     = optional(bool, false)

    # Auto-init and templates
    gitignore_template = optional(string, "")
    license_template   = optional(string, "")

    # Template repository configuration
    template = optional(object({
      owner                = string
      repository           = string
      include_all_branches = optional(bool, false)
    }), null)

    # Pages configuration
    pages = optional(object({
      build_type = optional(string, "workflow")
      cname      = optional(string, "")
      source = optional(object({
        branch = string
        path   = optional(string, "/")
      }), null)
    }), null)

    # Team permissions
    team_permissions = optional(map(string), {})

    # Optional environments - only define if needed
    environments = optional(map(object({
      wait_timer = optional(number, 0)
      required_reviewers = object({
        users = optional(list(string), [])
        teams = optional(list(string), [])
      })
    })), {})
  }))
  default = {}
}

# -----------------------------
# Common Labels & Milestones
# -----------------------------
variable "common_labels" {
  description = "GitHub labels to create in all repositories"
  type = list(object({
    name        = string
    color       = string
    description = optional(string)
  }))
  default = []
}

variable "common_milestones" {
  description = "GitHub milestones to create in all repositories"
  type = list(object({
    title       = string
    description = optional(string)
    due_date    = optional(string)
    state       = optional(string, "open")
  }))
  default = []
}

# -----------------------------
# Security Configuration
# -----------------------------
variable "security_config" {
  description = "Security configuration for all repositories"
  type = object({
    required_approving_review_count  = optional(number, 0)
    dismiss_stale_reviews            = optional(bool, true)
    require_code_owner_review        = optional(bool, false)
    require_last_push_approval       = optional(bool, true)
    required_conversation_resolution = optional(bool, true)
    require_signed_commits           = optional(bool, true)
    require_linear_history           = optional(bool, true)
    block_force_pushes               = optional(bool, true)
    block_deletions                  = optional(bool, true)

    # Status checks
    required_status_checks = optional(list(object({
      context        = string
      integration_id = optional(number)
    })), [])

    # Patterns
    commit_message_pattern = optional(object({
      pattern = string
      negate  = optional(bool, false)
      name    = optional(string, "Commit message must match pattern")
    }), null)

    branch_name_pattern = optional(object({
      pattern = string
      negate  = optional(bool, false)
      name    = optional(string, "Branch name must match pattern")
    }), null)
  })
  default = {}
}

# # -----------------------------
# # GitHub Plan Features
# # -----------------------------
variable "github_plan" {
  description = "GitHub plan to enable/disable features accordingly"
  type        = string
  default     = "free"

  validation {
    condition     = contains(["free", "pro"], var.github_plan)
    error_message = "GitHub plan must be one of: free, pro"
  }
}


