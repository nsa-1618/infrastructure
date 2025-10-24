#!/bin/bash

##############################################################################
# Team Portal Deployment Script
# 
# Purpose: Automated deployment of team-portal to Contabo server
# Usage: ./deploy-team-portal.sh
# Author: Nikolai Anton
# Date: 2025-10-24
##############################################################################

set -e  # Exit on error
set -o pipefail  # Catch errors in pipes

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="team-portal"
PROJECT_PATH="/home/nsa/team-portal"
CONTAINER_NAME="team-portal"
BACKUP_DIR="/home/nsa/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

##############################################################################
# Helper Functions
##############################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

##############################################################################
# Pre-flight Checks
##############################################################################

log_info "Starting deployment of ${PROJECT_NAME}..."
echo ""

# Check if running on correct server
if [ "$(hostname)" != "vmd181486" ]; then
    log_error "This script must run on Contabo server (vmd181486)"
    log_error "Current hostname: $(hostname)"
    exit 1
fi

log_success "Server check passed ($(hostname))"

# Check if project directory exists
if [ ! -d "$PROJECT_PATH" ]; then
    log_error "Project directory not found: $PROJECT_PATH"
    exit 1
fi

log_success "Project directory found"

# Check if git is available
if ! command -v git &> /dev/null; then
    log_error "Git is not installed"
    exit 1
fi

# Check if docker is available
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed"
    exit 1
fi

log_success "Pre-flight checks passed"
echo ""

##############################################################################
# Backup Current Version
##############################################################################

log_info "Creating backup..."

mkdir -p "$BACKUP_DIR"

BACKUP_FILE="${BACKUP_DIR}/${PROJECT_NAME}_${TIMESTAMP}.tar.gz"

cd "$PROJECT_PATH"
tar -czf "$BACKUP_FILE" \
    --exclude='node_modules' \
    --exclude='.git' \
    --exclude='__pycache__' \
    --exclude='.venv' \
    . 2>/dev/null || log_warning "Some files couldn't be backed up"

if [ -f "$BACKUP_FILE" ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    log_success "Backup created: $BACKUP_FILE ($BACKUP_SIZE)"
else
    log_warning "Backup failed, but continuing deployment..."
fi

echo ""

##############################################################################
# Git Pull
##############################################################################

log_info "Pulling latest code from GitHub..."

cd "$PROJECT_PATH"

# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
log_info "Current branch: $CURRENT_BRANCH"

# Fetch updates
git fetch origin

# Check if there are updates
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/$CURRENT_BRANCH)

if [ "$LOCAL" = "$REMOTE" ]; then
    log_warning "No updates available. Already up to date."
else
    # Pull updates
    git pull origin "$CURRENT_BRANCH"
    log_success "Code updated successfully"
fi

echo ""

##############################################################################
# Docker Build & Deploy
##############################################################################

log_info "Building and deploying container..."

cd "$PROJECT_PATH"

# Stop current container
log_info "Stopping current container..."
docker compose down

# Build new image
log_info "Building new Docker image..."
docker compose build --no-cache

# Start container
log_info "Starting container..."
docker compose up -d

log_success "Container started"
echo ""

##############################################################################
# Health Check
##############################################################################

log_info "Performing health check..."

# Wait for container to be ready
sleep 5

# Check if container is running
if docker ps | grep -q "$CONTAINER_NAME"; then
    log_success "Container is running"
    
    # Show container status
    docker ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
else
    log_error "Container failed to start!"
    log_error "Showing logs:"
    docker logs "$CONTAINER_NAME" --tail 50
    exit 1
fi

# Check if port is responding
sleep 2
if curl -s http://localhost:8511 > /dev/null; then
    log_success "Application is responding on port 8511"
else
    log_warning "Application not responding yet (may need more time)"
fi

echo ""

##############################################################################
# Summary
##############################################################################

log_success "Deployment completed successfully!"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "${GREEN}DEPLOYMENT SUMMARY${NC}"
echo "═══════════════════════════════════════════════════════════"
echo "Project:        $PROJECT_NAME"
echo "Timestamp:      $TIMESTAMP"
echo "Backup:         $BACKUP_FILE"
echo "Branch:         $CURRENT_BRANCH"
echo "Container:      $CONTAINER_NAME"
echo "Status:         Running ✅"
echo ""
echo "URLs:"
echo "  - http://wgl-lab.org:8511"
echo "  - http://207.180.207.183:8511"
echo ""
echo "Management:"
echo "  - Portainer: http://wgl-lab.org:9000"
echo "  - Logs: docker logs -f $CONTAINER_NAME"
echo "═══════════════════════════════════════════════════════════"
echo ""

##############################################################################
# Show Recent Logs
##############################################################################

log_info "Showing recent logs (Ctrl+C to exit)..."
echo ""
docker logs -f "$CONTAINER_NAME" --tail 20