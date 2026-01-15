#!/bin/bash

# MiroFish Log Viewer
# Interactive log viewing tool

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐟 MiroFish Log Viewer${NC}"
echo "======================"
echo ""
echo "Choose an option:"
echo "  1. View all logs (real-time)"
echo "  2. View backend logs only"
echo "  3. View frontend logs only"
echo "  4. Search for errors"
echo "  5. View last 50 lines"
echo "  6. View logs from last 30 minutes"
echo "  7. Save all logs to file"
echo "  8. View container logs directory"
echo ""
read -p "Enter choice [1-8]: " choice

case $choice in
    1)
        echo -e "\n${GREEN}Viewing all logs in real-time (Ctrl+C to exit)${NC}\n"
        docker compose logs -f
        ;;
    2)
        echo -e "\n${GREEN}Viewing backend logs (Ctrl+C to exit)${NC}\n"
        docker compose logs -f backend
        ;;
    3)
        echo -e "\n${GREEN}Viewing frontend logs (Ctrl+C to exit)${NC}\n"
        docker compose logs -f frontend
        ;;
    4)
        echo -e "\n${YELLOW}Searching for errors in all logs${NC}\n"
        docker compose logs | grep -i --color=always -E "error|exception|failed|traceback"
        ;;
    5)
        echo -e "\n${GREEN}Last 50 lines:${NC}\n"
        docker compose logs --tail=50
        ;;
    6)
        echo -e "\n${GREEN}Logs from last 30 minutes:${NC}\n"
        docker compose logs --since 30m
        ;;
    7)
        LOGFILE="mirofish-logs-$(date +%Y%m%d-%H%M%S).txt"
        echo -e "\n${GREEN}Saving logs to $LOGFILE${NC}\n"
        docker compose logs > "$LOGFILE"
        echo -e "${GREEN}✓${NC} Logs saved to: $LOGFILE"
        echo "File size: $(du -h "$LOGFILE" | cut -f1)"
        ;;
    8)
        echo -e "\n${GREEN}Container log files:${NC}\n"
        echo "Backend logs directory:"
        docker compose exec backend ls -lh /app/logs/ 2>/dev/null || echo "  No logs directory found"
        echo ""
        echo "Frontend Nginx logs:"
        docker compose exec frontend ls -lh /var/log/nginx/ 2>/dev/null || echo "  Unable to access Nginx logs"
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac
