<a id="readme-top"></a>

<!-- PROJECT LOGO & TITLE -->

<div align="center">
  <a href="https://github.com/opencloudhub/infra-modules">
    <img src="https://raw.githubusercontent.com/opencloudhub/.github/main/references/brand/assets/logos/primary-logo-light-background.svg" alt="OpenCloudHub Logo" width="100%" style="max-width:320px;" height="160">
  </a>

<h1 align="center">Infrastructure Modules</h1>

<!-- SORT DESCRIPTION -->

<p align="center">
    Reusable Terraform modules for OpenCloudHub MLOps platform infrastructure.<br />
    <a href="https://github.com/opencloudhub"><strong>Explore the organization »</strong></a>
  </p>

<!-- BADGES -->

<p align="center">
    <a href="https://github.com/opencloudhub/infra-modules/graphs/contributors">
      <img src="https://img.shields.io/github/contributors/opencloudhub/infra-modules.svg?style=for-the-badge" alt="Contributors">
    </a>
    <a href="https://github.com/opencloudhub/infra-modules/stargazers">
      <img src="https://img.shields.io/github/stars/opencloudhub/infra-modules.svg?style=for-the-badge" alt="Stars">
    </a>
    <a href="https://github.com/opencloudhub/infra-modules/issues">
      <img src="https://img.shields.io/github/issues/opencloudhub/infra-modules.svg?style=for-the-badge" alt="Issues">
    </a>
    <a href="https://github.com/opencloudhub/infra-modules/blob/main/LICENSE">
      <img src="https://img.shields.io/github/license/opencloudhub/infra-modules.svg?style=for-the-badge" alt="License">
    </a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->

<details>
  <summary>📑 Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#modules">Available Modules</a></li>
    <li><a href="#github-module-status">GitHub Module Status</a></li>
    <li><a href="#getting-started">Getting Started</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#known-limitations">Known Limitations</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

<h2 id="about-the-project">🏗️ About The Project</h2>

This repository contains reusable Terraform modules for the OpenCloudHub MLOps platform. These modules provide standardized infrastructure components that can be composed together to build complete environments across multiple cloud providers.

**Design Principles:**
- **🔄 Reusability**: DRY principle with configurable, composable modules
- **🌐 Multi-Cloud**: Support for Azure, DigitalOcean

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MODULES -->

<h2 id="modules">📦 Available Modules</h2>

### GitHub Management
- **`github/`** - Complete GitHub organization management
  - Organization settings and security policies
  - Team and membership management
  - Repository creation with security rulesets
  - Labels, milestones, and project management
  - **Status**: ✅ **Production Ready** (with limitations - see below)

### Cloud Infrastructure *(Coming Soon)*
- **`aws/`** - AWS infrastructure components
- **`azure/`** - Azure infrastructure components
- **`digitalocean/`** - DigitalOcean infrastructure components

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GITHUB MODULE STATUS -->

<h2 id="github-module-status">🚧 GitHub Module Status</h2>

### Current Capabilities

The GitHub module is **opinionated for personal accounts** and provides:

✅ **Core Features**
- Complete organization setup and configuration
- Team management with member assignments
- Repository creation with templates and settings
- Repository rulesets with security policies (PR reviews, branch protection, etc.)
- Common labels and milestones across all repositories
- Security features (secret scanning, dependency alerts) based on plan type

✅ **Plan Support**
- **Free Plan**: Public repos with security features, private repos with basic protection
- **Pro Plan**: Enhanced features for private repositories
- Plan-aware feature enablement (advanced security, secret scanning, etc.)

✅ **Security Features**
- Branch protection with required reviews and status checks
- Signed commits and linear history enforcement
- Team-based repository permissions
- Automated security scanning where available

### Planned Enhancements

🔄 **Future Team Features** *(when needed)*
- Organization rulesets (requires Teams plan)
- Advanced team permissions and SAML integration
- Custom repository roles
- Team-level security policies

### Important Limitations

⚠️ **Provider Maintenance Issues**
The GitHub Terraform provider has known maintenance challenges:
- ~300 open issues and limited active maintenance
- Some newer GitHub features may not be supported
- Edge cases may not be well documented

⚠️ **Validation Required**
Always verify that resources were created correctly:
```bash
# Check organization settings
gh api orgs/your-org

# Verify repository settings
gh api repos/your-org/repo-name

# Validate team permissions
gh api orgs/your-org/teams/team-name/repos
```

⚠️ **Feature Gaps**
- Organization-level commit signoff conflicts with repository-level settings
- Advanced security features auto-enabled for public repos (cannot be explicitly managed)
- Some newer GitHub features may not be available via Terraform

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->

<h2 id="getting-started">🚀 Getting Started</h2>

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.5.0
- [GitHub CLI](https://cli.github.com/) (recommended for validation)
- GitHub Personal Access Token with appropriate permissions

### GitHub Token Permissions

Your GitHub token needs these scopes:
- `admin:org` - Organization management
- `repo` - Repository management
- `user` - User and team management

### Usage in Your Project

Reference modules from this repository in your Terraform configuration:

```hcl
module "github_organization" {
  source = "git::https://github.com/opencloudhub/infra-modules.git//github?ref=v1.0.0"
  
  github_token = var.github_token
  github_owner = "your-org-name"
  
  organization_config = {
    billing_email = "admin@yourorg.com"
    company       = "Your Company"
    # Security settings
    web_commit_signoff_required = true
    # ... other settings
  }
  
  teams = {
    admin = {
      description = "Organization administrators"
      privacy     = "closed"
      members = [
        {
          username = "your-username"
          role     = "maintainer"
        }
      ]
    }
  }
  
  repositories = {
    "my-repo" = {
      description = "My awesome repository"
      visibility  = "public"
      team_permissions = {
        "admin" = "admin"
      }
    }
  }
  
  github_plan = "free"  # or "pro"
}
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE -->

<h2 id="usage">💡 Usage</h2>

### Quick Start with Terragrunt

The module is designed to work seamlessly with Terragrunt for environment management:

```hcl
# terragrunt.hcl
terraform {
  source = "git::https://github.com/opencloudhub/infra-modules.git//github?ref=v1.0.0"
}

inputs = {
  github_token        = get_env("GITHUB_TOKEN")
  github_owner        = "your-org"
  organization_config = jsondecode(file("organization.json"))
  teams              = jsondecode(file("teams.json"))
  repositories       = jsondecode(file("repositories.json"))
  # ... other configurations
}
```

### Module Documentation

Navigate to individual module directories for specific documentation:

- [`github/`](./github/) - GitHub organization management with examples
- More modules coming soon...

### Post-Apply Validation

Always validate your infrastructure after applying:

```bash
# Check organization settings
terraform output organization_config

# Verify teams were created correctly
terraform output teams

# Validate repository permissions
gh api orgs/your-org/teams/team-name/repos --jq '.[].permissions'
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- KNOWN LIMITATIONS -->

<h2 id="known-limitations">⚠️ Known Limitations</h2>

### GitHub Provider Issues

The GitHub Terraform provider has maintenance challenges that may affect this module:

1. **Limited Active Maintenance**: The provider has numerous open issues and PRs
2. **Feature Lag**: New GitHub features may not be immediately available
3. **Edge Case Bugs**: Some configurations may have undocumented issues

### Workarounds and Recommendations

- **Always validate**: Use GitHub CLI to verify resource creation
- **Test thoroughly**: Validate configurations in development first
- **Plan for manual fixes**: Some settings may need manual adjustment via GitHub UI
- **Pin versions**: Use specific module versions in production

### Migration Path

This module is designed for easy migration when:
- Your organization grows beyond personal account limits
- GitHub provider maintenance improves
- You need features not currently supported

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->

<h2 id="contributing">👥 Contributing</h2>

Contributions are welcome! Please see our [Contributing Guidelines](https://github.com/opencloudhub/.github/blob/main/CONTRIBUTING.md) for details.

### Module Development

1. **Create feature branch** from main
2. **Add/modify modules** following existing patterns
3. **Update documentation** with terraform-docs
4. **Test thoroughly** with `terraform validate` and real infrastructure
5. **Validate with GitHub CLI** - ensure resources were created correctly
6. **Create pull request** - CI checks will run automatically

### Reporting Issues

When reporting issues with the GitHub module:
- Include Terraform and provider versions
- Provide GitHub plan type (free/pro/team/enterprise)
- Test with GitHub CLI to distinguish provider vs. API issues

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->

<h2 id="license">📄 License</h2>

Distributed under the Apache License 2.0. See [LICENSE](LICENSE) for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

<div align="center">
  <h3>🌟 OpenCloudHub MLOps Platform</h3>
  <p><em>Building in public • Learning together • Sharing knowledge</em></p>

<div>
    <a href="https://opencloudhub.github.io/docs">
      <img src="https://img.shields.io/badge/Read%20the%20Docs-2596BE?style=for-the-badge&logo=read-the-docs&logoColor=white" alt="Documentation">
    </a>
    <a href="https://github.com/orgs/opencloudhub/discussions">
      <img src="https://img.shields.io/badge/Join%20Discussion-181717?style=for-the-badge&logo=github&logoColor=white" alt="Discussions">
    </a>
    <a href="https://github.com/orgs/opencloudhub/projects">
      <img src="https://img.shields.io/badge/View%20Roadmap-0052CC?style=for-the-badge&logo=jira&logoColor=white" alt="Roadmap">
    </a>
  </div>
</div>