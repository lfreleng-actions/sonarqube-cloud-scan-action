<!--
SPDX-License-Identifier: Apache-2.0
SPDX-FileCopyrightText: 2025 The Linux Foundation
-->

# 🔐 SonarQube Cloud Scan

Performs a SonarQube Cloud security scan of a given repository's code base.

Uploads the results to either the cloud service or an on-premise/hosted server.

## sonarqube-cloud-scan-action

## Required Credentials

The scanning action requires access to an API key for it to produce results.
Most projects configure this at the GitHub organisation level as:

`SONAR_TOKEN`

Optionally, set it at the repository level, but it MUST be available in the
Github environment for scans to produce results. For projects using Jenkins,
the same credential must be available to Jenkins jobs.

## Usage Example: Action

<!-- markdownlint-disable MD013 -->

```yaml
jobs:
  sonarqube-cloud:
    name: 'SonarQube Cloud Scan'
    runs-on: ubuntu-latest
    permissions:
        # Needed to upload the results to code-scanning dashboard
        security-events: write
        # Needed to publish results and get a badge (see publish_results below)
        id-token: write
        # Uncomment these below if installing in a private repository
        # contents: read
        # actions: read
    steps:
      - name: 'SonarQube Cloud Scan'
        uses: lfit-releng-reusable-workflows/.github/actions/sonarqube-cloud-scan-action@main
        with:
            SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

<!-- markdownlint-enable MD013 -->

## Usage Example: Reusable Workflow

See: <https://github.com/lfit/releng-reusable-workflows/blob/main/.github/workflows/reuse-sonarqube-cloud.yaml>

## Repository Contents and Scan Configuration

Provide information to the scanning action so that it understands how the
project/repository is setup. The accuracy of scans improves when provided with
the source code location (local directory) and for specific project types,
how to build it. For example, projects written in C (and related family of
languages) may need a wrapper script to invoke a build step/process. Provide
the path to the build wrapper either as arguments to the action, or add it
to the local repository configuration file.

Configure the scan parameters by creating either of these two files:

- sonar-project.properties
- sonarcloud.properties

As a temporary measure, in the absence of a configuration file, the scan action
will populate the file with these two parameters, enumerated at runtime:

```console
sonar.organization=[GITHUB REPOSITORY OWNER]
sonar.projectKey=[GITHUB REPOSITORY NAME]
```

This ensures that an initial scan for the repository will produce results in
portal. For further details on populating the scan configuration file with
the required information, refer to the documentation links in the section
below.

## SonarQube Cloud Documentation

Refer to the links below:

- <https://github.com/SonarSource/sonarqube-scan-action>
- <https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/scanners/sonarscanner/>

For information on the build wrapper for C language based projects:

<https://docs.sonarsource.com/sonarqube-cloud/advanced-setup/languages/c-family/prerequisites/#using-build-wrapper>

## Inputs

<!-- markdownlint-disable MD013 -->

| Variable Name         | Required | Default               | Description                                            |
| --------------------- | -------- | --------------------- | ------------------------------------------------------ |
| sonar_token           | True     | N/A                   | Mandatory authentication token to upload results       |
| sonar_root_cert       | False    | N/A                   | PEM encoded server root certificate (for HTTPS upload) |
| build_wrapper_url     | False    | N/A                   | Download location of build wrapper/shell script        |
| build_wrapper_out_dir | False    | N/A                   | Local filesystem location of build artefacts           |
| sonar_host_url        | False    | <https://sonarcloud.io> | Uploads scans to the given host URL                  |
| lc_all                | False    | en_US.UTF-8           | Locale for code base (if not covered by en_US.UTF-8)   |
| debug                 | False    | false                 | Enable debugging output                                |

<!-- markdownlint-enable MD013 -->
