#!/bin/bash

# MiroFish Docker Setup Validation Script
# This script validates the Docker configuration before deployment

set -e

echo "🔍 MiroFish Docker Setup Validation"
echo "===================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check functions
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} Found: $1"
        return 0
    else
        echo -e "${RED}✗${NC} Missing: $1"
        return 1
    fi
}

check_docker() {
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}✓${NC} Docker installed: $(docker --version)"
        return 0
    else
        echo -e "${RED}✗${NC} Docker not found"
        return 1
    fi
}

check_docker_compose() {
    if docker compose version &> /dev/null; then
        echo -e "${GREEN}✓${NC} Docker Compose installed: $(docker compose version)"
        return 0
    else
        echo -e "${RED}✗${NC} Docker Compose not found"
        return 1
    fi
}

# Counter for errors
ERRORS=0

echo "1. Checking Docker Installation"
echo "-------------------------------"
check_docker || ((ERRORS++))
check_docker_compose || ((ERRORS++))
echo ""

echo "2. Checking Docker Configuration Files"
echo "---------------------------------------"
check_file "docker-compose.yml" || ((ERRORS++))
check_file ".dockerignore" || ((ERRORS++))
check_file "backend/Dockerfile" || ((ERRORS++))
check_file "frontend/Dockerfile" || ((ERRORS++))
check_file "frontend/nginx.conf" || ((ERRORS++))
echo ""

echo "3. Checking Backend Files"
echo "-------------------------"
check_file "backend/run.py" || ((ERRORS++))
check_file "backend/requirements.txt" || ((ERRORS++))
check_file "backend/pyproject.toml" || ((ERRORS++))
check_file "backend/uv.lock" || ((ERRORS++))
check_file "backend/app/__init__.py" || ((ERRORS++))
echo ""

echo "4. Checking Frontend Files"
echo "---------------------------"
check_file "frontend/package.json" || ((ERRORS++))
check_file "frontend/vite.config.js" || ((ERRORS++))
check_file "frontend/src/main.js" || ((ERRORS++))
echo ""

echo "5. Checking Environment Configuration"
echo "--------------------------------------"
if [ -f ".env" ]; then
    echo -e "${GREEN}✓${NC} Found: .env"

    # Check for required environment variables
    if grep -q "LLM_API_KEY=your_api_key_here" .env 2>/dev/null; then
        echo -e "${YELLOW}⚠${NC}  Warning: LLM_API_KEY not configured (still using default)"
    else
        echo -e "${GREEN}✓${NC} LLM_API_KEY configured"
    fi

    if grep -q "ZEP_API_KEY=your_zep_api_key_here" .env 2>/dev/null; then
        echo -e "${YELLOW}⚠${NC}  Warning: ZEP_API_KEY not configured (still using default)"
    else
        echo -e "${GREEN}✓${NC} ZEP_API_KEY configured"
    fi
else
    echo -e "${YELLOW}⚠${NC}  .env file not found"
    echo -e "    ${YELLOW}→${NC} Create .env from .env.example: cp .env.example .env"
    ((ERRORS++))
fi

check_file ".env.example" || ((ERRORS++))
echo ""

echo "6. Validating docker-compose.yml Syntax"
echo "----------------------------------------"
if command -v docker &> /dev/null && docker compose version &> /dev/null; then
    if docker compose config --quiet 2>/dev/null; then
        echo -e "${GREEN}✓${NC} docker-compose.yml syntax is valid"
    else
        echo -e "${RED}✗${NC} docker-compose.yml has syntax errors"
        ((ERRORS++))
    fi
else
    echo -e "${YELLOW}⚠${NC}  Skipping validation (Docker not available)"
fi
echo ""

# Summary
echo "===================================="
echo "Summary"
echo "===================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓${NC} All checks passed! Ready to deploy."
    echo ""
    echo "Next steps:"
    echo "  1. Configure .env file with your API keys"
    echo "  2. Run: docker compose up -d --build"
    echo "  3. Access: http://localhost"
    exit 0
else
    echo -e "${RED}✗${NC} Found $ERRORS issue(s). Please fix them before deploying."
    echo ""
    echo "For help, see: DOCKER_DEPLOYMENT.md"
    exit 1
fi
