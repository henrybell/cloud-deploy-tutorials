/**
 * Copyright Google LLC 2021
 * Google Confidential, Pre-GA Offering for Google Cloud Platform
 * (see https://cloud.google.com/terms/service-terms)
 */

resource "google_artifact_registry_repository" "artifact-registry" {

  provider = google-beta

  location      = var.region
  repository_id = "web-app"
  description   = "Image registry for tutorial web app"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository" "artifact-registry-profiles" {

  provider = google-beta

  location      = var.region
  repository_id = "web-app-profiles"
  description   = "Image registry for tutorial web app with Skaffold profiles"
  format        = "DOCKER"
}
