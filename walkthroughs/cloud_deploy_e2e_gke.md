<walkthrough-author
    tutorialname="Cloud Deploy Tutorial"
    repositoryUrl="https://clouddeploy.googlesource.com/tutorial"
    >
</walkthrough-author>

<!-- descriptive tutorial name? --sanderbogdan -->
# Cloud Deploy: Private Preview
## Overview
This tutorial guides you through setting up and using the Google Cloud Deploy service.

You will create a GCP Project (or use an existing one if you want), to create a complete **test > staging > production** delivery pipeline using Cloud Deploy.

<!-- TODO: We need a graphic/logo/something here for impact. Possibly a graphic of the dev > staging > prod pipeline for emphasis? -->

### About Cloud Shell
This tutorial uses [Google Cloud Shell](https://cloud.google.com/shell) to configure and interact with Cloud Deploy. Cloud Shell is an online development and operations environment, accessible anywhere with your browser. 

You can manage your resources with its online terminal, preloaded with utilities such as the `gcloud`, `kubectl`, and more. You can also develop, build, debug, and deploy your cloud-based apps using the online [Cloud Shell Editor](https://ide.cloud.google.com/).

<!-- TODO: Will it? If so, add link -->
### Supporting materials
Estimated Duration:
<walkthrough-tutorial-duration duration="20"></walkthrough-tutorial-duration>

Click **Start** to proceed.

## Select a project
Choose a project for this tutorial. The project will contain the Cloud Deploy service and the GKE clusters that will act as your development, staging, and production environments.

_We recommend you create a new project for this tutorial. You may experience undesired side effects if you use an existing project with conflicting settings._

<walkthrough-project-setup></walkthrough-project-setup>

Click **Next** to proceed.

## Prepare Cloud Shell
You'll use Cloud Shell for this tutorial. Open Cloud Shell in your browser by clicking the Cloud Shell icon <walkthrough-cloud-shell-icon></walkthrough-cloud-shell-icon>. 

If you don't see the Cloud Shell icon in your window, you can click this button to open it:

<walkthrough-open-cloud-shell-button></walkthrough-open-cloud-shell-button>

Next, you'll download the tutorial code base to your Cloud Shell.

### Clone the tutorial repository
<!-- I am wondering if we include this in bootstrap.sh, as we did with the Experiment tutorial? wdybt? --sanderbogdan 
sgtm --ddorbin
-->
The source code for this tutorial is housed in a git repository. Your Cloud Shell already has `git` pre-installed.

Run the following command to clone the tutorial repository:

```bash
git clone https://clouddeploy.googlesource.com/tutorial
```

This puts the tutorial source code you'll use into a `tutorial` folder in your Cloud Shell home directory.

Click **Next** to proceed.

## Deploy tutorial infrastructure
<!-- I am wondering if we include this in bootstrap.sh, as we did with the Experiment tutorial? wdybt? --sanderbogdan -->
You'll deploy three GKE clusters with the following names into your `{{project-id}}` Project: 

* `test`
* `staging`
* `prod`

_Note_: If you have an existing GKE cluster in `{{project-id}}` with any of these names, you need to select a different project.

<!-- Does the user need to know that it's a VPC, in the context of this tutorial? -->
These three clusters are deployed into a Virtual Private Cloud in `{{project-id}}`. 

<!-- TODO: A graphic would help this be understood better. Simple squares with VPCs etc -->

Run `bootstrap.sh` in your Cloud Shell to create the GKE clusters and supporting resources:

```bash
cd tutorial
./bootstrap.sh
```

This might take a few minutes to run. 

After the script finishes, confirm that your GKE clusters and supporting resources are properly deployed:

```bash
gcloud container clusters list
```

Your output should look like this:

```terminal
NAME     LOCATION     MASTER_VERSION    MASTER_IP       MACHINE_TYPE   NODE_VERSION      NUM_NODES  STATUS
prod     us-central1  1.17.17-gke.2800  35.194.37.64    n1-standard-2  1.17.17-gke.2800  3          RUNNING
staging  us-central1  1.17.17-gke.2800  35.232.139.69   n1-standard-2  1.17.17-gke.2800  3          RUNNING
test     us-central1  1.17.17-gke.2800  35.188.180.217  n1-standard-2  1.17.17-gke.2800  3          RUNNING
```

If the command succeeds, each cluster will have three nodes and a `RUNNING` status.

Click **Next** to proceed.

## Create tutorial environment
You're now ready to begin configuring Cloud Deploy.


<!-- TODO: Keep this updated depending on the app lifecycle -->
### Enable the Cloud Deploy API
<!-- I am wondering if we include this in bootstrap.sh, as we did with the Experiment tutorial? wdybt? --sanderbogdan -->
<!-- TODO: This may change or be wholly unneeded. I'm leaving it here for current testing if nothing else --jduncan -->
<!-- COMMENT: I like the fact that we how how to enable the API programmatically, but perhaps this part of the boostrap.sh? Conversely, the CLI to do this is a bit knotty - hopefully that will be able to simplified forward as well? --sanderbogdan -->
<!-- COMMENT: yeah, this is just a placeholder until we get to the prod API -->
To enable the Cloud Deploy service and related APIs, run the following command:

```bash
gcloud config set api_endpoint_overrides/clouddeploy "https://staging-clouddeploy.sandbox.googleapis.com/"
gcloud services enable staging-clouddeploy.sandbox.googleapis.com --project={{project-id}}
```

### Configure Cloud Deploy
Default Cloud Deploy parameters can be configured with `gcloud` to avoid typing them for every command.

Run the following command in Cloud Shell to set a default region for the rest of the commands in this tutorial: 

```bash
gcloud config set deploy/region $REGION
```

This will be used for any additonal Cloud Deploy commands unless you override it using the `--region` parameter.

<!-- COMMENT: I think this should be a pointer to the Cloud Deploy CLI documentation / or perhaps there is a gcloud CLI document regarding common defaults. TODO: follow up on link recommendation with ddorbin@ --sanderbogdan 
I'm in favor of removing this entirely --ddorbin
The config we just set is region, which isn't a CD-specific config, so I'm not sure what we're trying to offer with the next sentence.
-->
The full list of Cloud Deploy configurations is available at [TODO].

You are now ready to deploy your first Cloud Deploy resource in your project.

Click **Next** to proceed.

## Create the delivery pipeline

Cloud Deploy uses YAML files to define `delivery-pipeline` and `target` resources. For this tutorial, we have pre-created these files in the repository you cloned in Step 2.
<!-- COMMENT: May want to reference specific step # here. --sanderbogdan 
I added that. Look ok? -->

<!-- COMMENT: We can consider adding linkings to the external facing Cloud Deploy resource documentation for Public Preview --sanderbogdan -->
In this tutorial, you will create a Cloud Deploy _delivery pipeline_ that progresses a web application through three _targets_: `test`, `staging`, and `prod`.

<walkthrough-editor-select-line filePath="tutorial/clouddeploy-config/delivery-pipeline.yaml" startLine="11" startCharacterOffset="0" endLine="19" endCharacterOffset="99">Click here to review the delivery pipeline YAML</walkthrough-editor-select-line>
 
The following command creates the `delivery-pipeline` resource using the delivery pipeline YAML file: 

```bash
gcloud alpha deploy apply --file=clouddeploy-config/delivery-pipeline.yaml 
```

Verify the delivery pipeline was created:

<!-- TODO: consider doing a get here instead of list, particularly since we do a list with targets? wdybt? --sanderbogdan -->
```bash
gcloud alpha deploy delivery-pipelines list
```

The output should look like this:

```terminal
---
createTime: '2021-04-12T18:34:02.614196898Z'
description: web-app delivery pipeline
etag: 2539eacd7f5c256d
name: projects/your-project/locations/us-central1/deliveryPipelines/web-app
serialPipeline:
  stages:
  - targetId: test
  - targetId: staging
  - targetId: prod
uid: b116d89067e64d7eb63f37fe5e99d1ff
updateTime: '2021-04-12T18:34:04.936664219Z'
```

With your delivery pipeline confirmed, you're ready to create the three _targets_.

Click **Next** to proceed.

## Create the test target
In Cloud Deploy, a _target_ represents a GKE cluster where an application can be deployed as part of a delivery pipeline.

In the tutorial delivery pipeline, the first target is `test`. 

You create a `target` by applying a YAML file to Cloud Deploy using `glcoud alpha deploy apply`.

<walkthrough-editor-select-line filePath="tutorial/clouddeploy-config/test-environment.yaml" startLine="11" startCharacterOffset="0" endLine="19" endCharacterOffset="99">Click here to view the `test` target YAML</walkthrough-editor-select-line>

Create the `test` target: 

```bash
gcloud alpha deploy apply --file clouddeploy-config/test-environment.yaml
```

Verify the `target` was created using `gcloud alpha deploy` to list `target`s.

```bash
gcloud alpha deploy targets list --delivery-pipeline=web-app
```

The output should look like this:

```terminal
---
createTime: '2021-04-15T13:53:31.094996057Z'
description: test cluster
etag: 4c7d828d4f7a3b74
gkeCluster:
  cluster: test
  location: us-central1˜
  project: your-project
name: projects/your-project/locations/us-central1/deliveryPipelines/web-app/targets/test
uid: d1d2ca2dc4bf4884a8d16588cfe6d458
updateTime: '2021-04-15T13:53:31.663277590Z'
```

Click **Next** to proceed.

## Create staging and prod targets
In this section, you create targets for the `staging` and `prod` clusters. The process is the same as for the `test` target you just created. 

Start by creating the `staging` target.

<walkthrough-editor-select-line filePath="tutorial/clouddeploy-config/staging-environment.yaml" startLine="11" startCharacterOffset="0" endLine="19" endCharacterOffset="99">Click here to view the `staging` target YAML</walkthrough-editor-select-line>

Apply the `staging` target definition: 

```bash
gcloud alpha deploy apply --file clouddeploy-config/staging-environment.yaml
```

Repeat the process for the `prod` target.

<walkthrough-editor-select-line filePath="tutorial/clouddeploy-config/prod-environment.yaml" startLine="11" startCharacterOffset="0" endLine="19" endCharacterOffset="99">Click here to view your `prod` target YAML</walkthrough-editor-select-line>

Apply the `prod` target definition:

```bash
gcloud alpha deploy apply --file clouddeploy-config/prod-environment.yaml
```

Verify both targets for the `web-app` delivery pipeline:

```bash
gcloud alpha deploy targets list --delivery-pipeline=web-app
```

The output should look like this:

```terminal
---
createTime: '2021-04-15T16:43:59.404939886Z'
description: staging cluster
etag: 9c923d5f1dd88c97
gkeCluster:
  cluster: staging
  location: us-central1˜
  project: your-project
name: projects/your-project/locations/us-central1/deliveryPipelines/web-app/targets/staging
uid: b1a856d72e5d43de817c2ea8380da39b
updateTime: '2021-04-15T16:44:00.272725580Z'
---
createTime: '2021-04-15T13:53:31.094996057Z'
description: test cluster
etag: 4c7d828d4f7a3b74
gkeCluster:
  cluster: test
  location: us-central1˜
  project: your-project
name: projects/your-project/locations/us-central1/deliveryPipelines/web-app/targets/test
uid: d1d2ca2dc4bf4884a8d16588cfe6d458
updateTime: '2021-04-15T13:53:31.663277590Z'
---
createTime: '2021-04-15T16:44:31.295700Z'
description: prod cluster
etag: ff1840e2d8c3010a
gkeCluster:
  cluster: prod
  location: us-central1
  project: your-project
name: projects/your-project/locations/us-central1/deliveryPipelines/web-app/targets/prod
uid: 0c22c1fb08e546ee9ae569ce501bac95
updateTime: '2021-04-15T16:44:32.078235982Z'
```

All Cloud Deploy targets for the delivery pipeline have now been created.

Click **Next** to proceed.

## Build the Application
<!-- TODO: We should check with viglesias@ regarding how he wants to position this copy --sanderbogdan -->
Cloud Deploy integrates with [`skaffold`](https://skaffold.dev/), a leading open-source continuous-development toolset.

As part of this tutorial, a sample application has been cloned from a [Github repository](https://github.com/GoogleContainerTools/skaffold.git) to your Cloud Shell instance, in the `web` directory. 

In this section, you'll build that application image so you can progress it through the `webapp` delivery pipeline.

### Configure Artifact Registry authentication
Google Cloud's Artifact Registry was enabled as part of this tutorial. To push a container image to the registry, you need to enable the `docker` daemon so you can log in to Artifact Registry using your active SDK authentication token. 

The commands below allow your user to run `docker` commands on Cloud Shell and also configure the local `docker` daemon to authenticate using `gcloud` for your Artifact Registry domain.

```bash
sudo usermod -a -G docker ${USER}
gcloud auth configure-docker ${REGION}-docker.pkg.dev
```

Authenticate to Artifact Registry: 

```bash
docker login ${REGION}-docker.pkg.dev
```

This allows `skaffold` to push your image to Artifact Registry.

### Build with Skaffold

The example application source code is in the `web` directory of your Cloud Shell instance. That directory contains `skaffold.yaml`, which contains instructions for `skaffold` to build a container image for your application.

<walkthrough-editor-select-line filePath="tutorial/web/skaffold.yaml" startLine="11" startCharacterOffset="0" endLine="19" endCharacterOffset="99">Click here to view the `web-app` `skaffold.yaml`.</walkthrough-editor-select-line>

When deployed, the application images are named `leeroy-web` and `leeroy-app`. To create these container images, run the following command:

```bash
cd web/
skaffold build --default-repo ${REGION}-docker.pkg.dev/{{project-id}}/web-app
```

Confirm the images were successfully pushed to Artifact Registry:

```bash
gcloud artifacts docker images list ${REGION}-docker.pkg.dev/${PROJECT_ID}/web-app --include-tags --format json
```
The `--format json` parameter returns the output as JSON for readability. The output should look like this: 

```terminal
Listing items under project your-project, location us-central1, repository web-app.

[
  {
    "createTime": "2021-04-15T23:15:15.792959Z",
    "package": "us-central1-docker.pkg.dev/your-project/web-app/leeroy-app",    
    "tags": "63ec18a",
    "updateTime": "2021-04-15T23:15:15.792959Z",
    "version": "sha256:80d8a867b82eb402ebe5b48f972c65c2b4cf7657ab30b03dd7b0b21dfc4a6792"
  },
  {
    "createTime": "2021-04-15T23:15:27.320207Z",
    "package": "us-central1-docker.pkg.dev/your-project/web-app/leeroy-web",
    "tags": "63ec18a",
    "updateTime": "2021-04-15T23:15:27.320207Z",
    "version": "sha256:30c37ef69eaf759b8c151adea99b6e8cdde85a81b073b101fbc593eab98bc102"
  }
]
```

By default, `skaffold` sets the tag for an image to the short form of the `git` commit ID. You can use this to verify the image being added to a Cloud Deploy `release`.

### Verify the Application Image
Run the following `git` command to ensure there were no issues when building or pushing the application image:

```bash
export GIT_SHA=$(git rev-parse --short HEAD)
```

This value should match the `tags` value in the Artifact Registry output from above.

```bash
gcloud artifacts docker images list ${REGION}-docker.pkg.dev/${PROJECT_ID}/web-app --include-tags --format=value"(package,tags)"
```

The output should look like this (but with different commit IDs): 

```terminal
Listing items under project your-project, location us-central1, repository web-app.

us-central1-docker.pkg.dev/{{project-id}}/web-app/leeroy-app      63ec18a
us-central1-docker.pkg.dev/{{project-id}}/web-app/leeroy-web      63ec18a
```

You can confirm the output matches the git commit ID.
```bash
echo $GIT_SHA
```

If the values match, your application container images are now built, verified, and ready for Cloud Deploy. 

Click **Next** to proceed.

## Create a Release
<!-- TODO: A release, technically, also includes the rendering source and skaffold.yaml; we should somehow weave a statement regarding this into this section, also (IMHO). --sanderbogdan -->
A Cloud Deploy `release` is a specific version of one or more application images associated with a specific delivery pipeline. Once a release is created, it can be promoted through multiple targets (the _promotion sequence_).

Because this is the first release of our application, we'll name it `web-app-001`.

Run the following command to create the release:

```bash
gcloud alpha deploy releases create web-app-001 --delivery-pipeline web-app --images leeroy-web=${REGION}-docker.pkg.dev/{{project-id}}/web-app/leeroy-web:${GIT_SHA},leeroy-app=${REGION}-docker.pkg.dev/{{project-id}}/web-app/leeroy-app:${GIT_SHA} --source web/
```

The command above references the delivery pipeline and the container images you created earlier in this tutorial.

To confirm your release has been created run the following command: 

```bash
gcloud alpha deploy releases list --delivery-pipeline web-app
```

Your output should look similar to this: 

```terminal
---
buildArtifacts:
- imageName: leeroy-app
  tag: 'us-central1-docker.pkg.dev/{{project-id}}/web-app/leeroy-app:'- imageName: leeroy-web
  tag: 'us-central1-docker.pkg.dev/{{project-id}}/web-app/leeroy-web:'
createTime: '2021-04-29T00:30:59.672965025Z'deliveryPipelineSnapshot:
  createTime: '1970-01-01T00:00:30.486775Z'
  description: web-app delivery pipeline
  etag: 2539eacd7f5c256d
  name: projects/619472186817/locations/us-central1/deliveryPipelines/web-app
  serialPipeline:
    stages:
    - targetId: test
    - targetId: staging
    - targetId: prod
```

With your release created, it's time to promote your application through your environments. 

Click **Next** to proceed.

## Promotion

With your release created, you can promote your application to your `test` Target GKE cluster. To promote your `web-app-001` release, run the following command:

```bash
gcloud alpha deploy releases promote --delivery-pipeline web-app --release web-app-001 --to-target test
```
Your output should look similar to this: 

```terminal
rollout:
  rollout: web-app-001-to-test-0002
  target: test
```

The promotion command should return quickly. But your actual application deployment may take a few minutes to your GKE cluster because it has to download your application images from your Artifact Registry. To confirm your promotion was successful, run the following command:

```bash
gcloud alpha deploy rollouts list --delivery-pipeline web-app --release web-app-001
```

Your output should look similar to this:

```terminal
---
createTime: '2021-04-30T18:46:45.657293361Z'
deployBuild: 3915c189-e9b4-4c6e-b757-322d8db18188
deployEndTime: '2021-04-30T18:47:31.951451Z'
deployStartTime: '2021-04-30T18:46:47.234151706Z'
etag: d4a044da3c830258
name: projects/{{project-id}}/locations/us-central1/deliveryPipelines/web-app/releases/web-app-001/rollouts/web-app-001-to-test-0002
state: SUCCESS
target: test
uid: f37126ebe3764108beb081c7e2930d7a
```

To confirm your application was deployed to your test GKE cluster, run the following commands in your Cloud Shell: 

```bash
kubectx test
kubectl get pods -n default
```

The output of your `kubectl` command should look similar to the following: 

```terminal
NAME                          READY   STATUS    RESTARTS   AGE
leeroy-app-7b8d48f794-svl6g   1/1     Running   0          19s
leeroy-web-5498c5b7fd-czvm8   1/1     Running   0          20s
```

To promote your application to your staging Target, run the following command: 

```bash
gcloud alpha deploy releases promote --delivery-pipeline web-app --release web-app-001 --to-target staging
```

You can verify this promotion was successful using the same steps as above for Cloud Deploy as well as your `staging` GKE cluster.

In the next section, you'll modify your `prod` target to require an approval and finally deploy your Release to production.

Click **Next** to proceed. 

## Approvals

Any Target can require an Approval before a Release promotion can occur. This is designed to protect production and sensitive Targets from accidentally promoting a release before it's been fully vetted and tested.

### Requiring Approval for Promotion to a Target

When you created your prod environment, the configuration was in place to require approvals to this Target. To verify this, run this command and look for the `approvalRequired` parameter.

```bash
$ gcloud alpha deploy targets describe prod --delivery-pipeline web-app
```

Your output should look similar to this: 

```terminal
Target:
  approvalRequired: true
  createTime: '2021-04-30T18:40:11.068571913Z'
  description: prod cluster
  etag: 74a0c6560ae0ace7
  gkeCluster:
    cluster: prod
    location: us-central1
    project: {{project-id}}
  name: projects/{{project-id}}/locations/us-central1/deliveryPipelines/web-app/targets/prod
  uid: 95fbe354bc07435f8248712a44035ca0
  updateTime: '2021-04-30T20:39:57.398607646Z'
```

Go ahead and promote your application to your prod Target with this command 

```bash
gcloud alpha deploy rollouts list --delivery-pipeline web-app --release web-app-001
```

When you look at your rollouts for `web-app-001`, you'll notice that the promotion to prod has a `PENDING_APPROVAL` status.

```terminal
approvalState: NEEDS_APPROVAL
createTime: '2021-05-03T17:23:18.183598192Z'
etag: ac30600d82dcb0f
name: projects/{{project-id}}/locations/us-central1/deliveryPipelines/web-app/releases/web-app-001/rollouts/web-app-001-to-prod-0001
state: PENDING_APPROVAL
target: prod
uid: f7de1bc9af4e46e499cc0c134b3758a6
```

Next, you'll create a user with the proper IAM roles to approve this promotion to your prod Target and make your production push. 

Click **Next** to proceed.

### Defining Approvers through IAM

<!-- TODO - doesn't work in CLI yet -->

With your user properly enabled, you can now promote your application to your prod Target. 

Click **Next** to proceed.

### Deploying to Prod

To approve your application and promote it to your prod Target, use this command: 

```bash
gcloud alpha deploy rollouts approve web-app-001-to-prod-0001 --delivery-pipeline web-app --release web-app-001
```

After a short time, your promotion should complete. Verify this by running the `gcloud alpha deploy rollouts list --delivery-pipeline web-app` command: 

```bash
gcloud alpha deploy rollouts list --delivery-pipeline web-app --release web-app-001
```

Your output should look similar to this: 

```terminal
approvalState: APPROVED
createTime: '2021-05-03T17:23:18.183598192Z'
deployBuild: 27c9a286-2a88-419e-be5b-a79fa6248f60
deployEndTime: '2021-05-03T19:00:26.526217Z'
deployStartTime: '2021-05-03T18:59:46.114953201Z'
etag: 205ff1e1a8d8c4f6
name: projects/{{project-id}}/locations/us-central1/deliveryPipelines/web-app/releases/web-app-001/rollouts/web-app-001-to-prod-0001
state: SUCCESS
target: prod
uid: f7de1bc9af4e46e499cc0c134b3758a6
```

You can also confirm your `prod` GKE cluster has your apps deployed: 

```bash
kubectx prod
kubectl get pod -n default
```

Your Cloud Deploy workflow approval worked, and your application is now deployed to your prod GKE cluster.

In the next section you'll roll an application back. 

Click **Next** to proceed.

## Rollback
<!-- TODO: details; create a second release, rollback test target -->

## Cloud Deploy Console
<!-- TODO: Couple short paragraphs, pivot out to review Delivery Pipeline and details in Cloud Console -->

# Advanced use
<!-- TODO: review with Jamie/Henry this week -->

## Use Skaffold profiles
<!-- TODO: Helm or Kustomize? Simple sample, similar to the prior Experiment tutorial to demonstrate how to use Skaffold + profiles -->

## Notifications
<!-- TODO: I feel a very simple example, with some post deployment notification message hook that prints a message is good enough. We can use this step's copy to express  -->