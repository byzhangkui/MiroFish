#!/bin/bash

# MiroFish Docker Quick Start Script
# This script helps you quickly start MiroFish with Docker

set -e

echo "🐟 MiroFish Docker Quick Start"
echo "=============================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    echo "Please install Docker Compose first"
    exit 1
fi

echo -e "${GREEN}✓${NC} Docker and Docker Compose are installed"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠${NC}  .env file not found"
    echo ""
    echo "Creating .env from .env.example..."
    cp .env.example .env
    echo -e "${GREEN}✓${NC} .env file created"
    echo ""
    echo -e "${YELLOW}⚠${NC}  Please edit .env file and configure your API keys:"
    echo "   - LLM_API_KEY (required)"
    echo "   - ZEP_API_KEY (required)"
    echo ""
    echo "After configuring, run this script again."
    exit 0
fi

# Check if API keys are configured
if grep -q "your_api_key_here" .env 2>/dev/null; then
    echo -e "${YELLOW}⚠${NC}  API keys not configured in .env file"
    echo ""
    echo "Please edit .env file and replace:"
    echo "   - LLM_API_KEY=your_api_key_here"
    echo "   - ZEP_API_KEY=your_zep_api_key_here"
    echo ""
    echo "With your actual API keys."
    read -p "Do you want to continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

echo -e "${GREEN}✓${NC} .env file configured"
echo ""

# Ask user for start mode
echo "Choose start mode:"
echo "  1. Start in background (recommended)"
echo "  2. Start in foreground (show logs)"
echo ""
read -p "Enter choice [1-2]: " choice

case $choice in
    1)
        echo ""
        echo "🚀 Starting MiroFish in background..."
        docker compose up -d --build
        echo ""
        echo -e "${GREEN}✓${NC} MiroFish started successfully!"
        echo ""
        echo "Access the application:"
        echo "  - Frontend: http://localhost"
        echo "  - Backend:  http://localhost:5001"
        echo ""
        echo "Useful commands:"
        echo "  - View logs:    docker compose logs -f"
        echo "  - Stop:         docker compose down"
        echo "  - Restart:      docker compose restart"
        echo ""
        echo "Checking service status..."
        sleep 3
        docker compose ps
        ;;
    2)
        echo ""
        echo "🚀 Starting MiroFish in foreground..."
        echo "Press Ctrl+C to stop"
        echo ""
        docker compose up --build
        ;;
    *)
        echo -e "${RED}❌ Invalid choice${NC}"
        exit 1
        ;;
esac
