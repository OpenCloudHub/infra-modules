# modules/github/teams.tf

# -----------------------------
# Teams
# -----------------------------
resource "github_team" "all" {
  for_each = var.teams

  name        = each.key
  description = each.value.description
  privacy     = each.value.privacy
}

# -----------------------------
# Team Memberships
# -----------------------------
resource "github_team_membership" "all" {
  for_each = local.team_memberships

  team_id  = github_team.all[each.value.team].id
  username = each.value.username
  role     = each.value.role
}
