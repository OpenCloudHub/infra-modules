# modules/github/organization.tf

# -----------------------------
# Organization Settings
# -----------------------------
resource "github_organization_settings" "main" {
  billing_email = var.organization_config.billing_email
  company       = var.organization_config.company
  blog          = var.organization_config.blog
  email         = var.organization_config.email
  location      = var.organization_config.location
  description   = var.organization_config.description

  # Project settings
  has_organization_projects = var.organization_config.has_organization_projects
  has_repository_projects   = var.organization_config.has_repository_projects

  # Default permissions
  default_repository_permission = var.organization_config.default_repository_permission

  # Member permissions
  members_can_create_repositories         = var.organization_config.members_can_create_repositories
  members_can_create_public_repositories  = var.organization_config.members_can_create_public_repositories
  members_can_create_private_repositories = var.organization_config.members_can_create_private_repositories
  members_can_create_pages                = var.organization_config.members_can_create_pages
  members_can_fork_private_repositories   = var.organization_config.members_can_fork_private_repositories

  # Security settings
  web_commit_signoff_required                                  = var.organization_config.web_commit_signoff_required
  advanced_security_enabled_for_new_repositories               = var.organization_config.advanced_security_enabled_for_new_repositories
  dependabot_alerts_enabled_for_new_repositories               = var.organization_config.dependabot_alerts_enabled_for_new_repositories
  dependabot_security_updates_enabled_for_new_repositories     = var.organization_config.dependabot_security_updates_enabled_for_new_repositories
  dependency_graph_enabled_for_new_repositories                = var.organization_config.dependency_graph_enabled_for_new_repositories
  secret_scanning_enabled_for_new_repositories                 = var.organization_config.secret_scanning_enabled_for_new_repositories
  secret_scanning_push_protection_enabled_for_new_repositories = var.organization_config.secret_scanning_push_protection_enabled_for_new_repositories
}

# -----------------------------
# Organization Members
# -----------------------------
resource "github_membership" "all" {
  for_each = var.organization_members

  username = each.value.username
  role     = each.value.role
}

# -----------------------------
# Organization Ruleset
# Build and use later instead of branch rulesets to enforce basic security policies
# checks, workflows, etc, organization wide. You might want to keep branch specific
# rulesets for more specific cases ( Mergequeue support, targeting specific repos with more
# restrictive rules )
# -----------------------------
