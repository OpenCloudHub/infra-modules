# modules/github/locals.tf

# -----------------------------
# Plan Feature Matrix
# -----------------------------
locals {
  personal_plan_features = {
    free = {
      public = {
        advanced_security = true
        secret_scanning   = true
        push_protection   = true
        rulesets          = true
      }
      private = {
        advanced_security = false
        secret_scanning   = false
        push_protection   = false
        rulesets          = false
      }
    }

    pro = {
      public = {
        advanced_security = true
        secret_scanning   = true
        push_protection   = true
        rulesets          = true
      }
      private = {
        advanced_security = false
        secret_scanning   = false
        push_protection   = false
        rulesets          = true
      }
    }
  }

  current_plan_matrix = local.personal_plan_features[var.github_plan]

  repo_features = {
    for repo_key, repo in var.repositories :
    repo_key => {
      visibility                = repo.visibility
      advanced_security_enabled = local.current_plan_matrix[repo.visibility].advanced_security
      secret_scanning_enabled   = local.current_plan_matrix[repo.visibility].secret_scanning
      push_protection_enabled   = local.current_plan_matrix[repo.visibility].push_protection
      rulesets_enabled          = local.current_plan_matrix[repo.visibility].rulesets
    }
  }
}

# -----------------------------
# Local transformations
# -----------------------------
locals {
  # Transform teams JSON array structure to map for Terraform processing
  team_memberships = {
    for item in flatten([
      for team_name, team in var.teams : [
        for member in team.members : {
          key      = "${team_name}:${member.username}"
          team     = team_name
          username = member.username
          role     = try(member.role, "member")
        }
      ]
    ]) : item.key => item
  }
}

