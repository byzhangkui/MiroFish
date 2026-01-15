#!/bin/bash

# MiroFish Access Diagnostic Script
# Checks network configuration and provides access URLs

echo "🔍 MiroFish Access Diagnostic"
echo "=============================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 1. Check Docker containers
echo "1. Checking Docker containers..."
if docker compose ps &> /dev/null; then
    docker compose ps
    echo ""
else
    echo -e "${RED}✗${NC} Unable to check Docker containers (is Docker running?)"
    echo ""
fi

# 2. Get IP addresses
echo "2. Network Information"
echo "----------------------"

# Get local IP
LOCAL_IPS=$(hostname -I 2>/dev/null | tr ' ' '\n' | grep -v '^$')
echo -e "${BLUE}Local/Private IPs:${NC}"
echo "$LOCAL_IPS" | while read ip; do
    echo "  - $ip"
done
echo ""

# Try to get public IP
echo -e "${BLUE}Public IP:${NC}"
PUBLIC_IP=$(timeout 5 curl -s ifconfig.me 2>/dev/null || timeout 5 curl -s ip.sb 2>/dev/null || echo "")
if [ -n "$PUBLIC_IP" ]; then
    echo "  - $PUBLIC_IP"
else
    echo -e "  ${YELLOW}Unable to detect (may not have public IP or network restricted)${NC}"
fi
echo ""

# 3. Check port listening
echo "3. Port Status"
echo "--------------"
if command -v netstat &> /dev/null; then
    PORT_80=$(netstat -tln | grep ':80 ')
    PORT_5001=$(netstat -tln | grep ':5001 ')
elif command -v ss &> /dev/null; then
    PORT_80=$(ss -tln | grep ':80 ')
    PORT_5001=$(ss -tln | grep ':5001 ')
else
    PORT_80=""
    PORT_5001=""
fi

if [ -n "$PORT_80" ]; then
    echo -e "${GREEN}✓${NC} Port 80 (Frontend) is listening"
else
    echo -e "${RED}✗${NC} Port 80 (Frontend) is NOT listening"
fi

if [ -n "$PORT_5001" ]; then
    echo -e "${GREEN}✓${NC} Port 5001 (Backend) is listening"
else
    echo -e "${RED}✗${NC} Port 5001 (Backend) is NOT listening"
fi
echo ""

# 4. Test local access
echo "4. Testing Local Access"
echo "-----------------------"

# Test frontend
if curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null | grep -q "200\|301\|302"; then
    echo -e "${GREEN}✓${NC} Frontend responding on http://localhost"
else
    echo -e "${RED}✗${NC} Frontend NOT responding on http://localhost"
fi

# Test backend
BACKEND_STATUS=$(curl -s http://localhost:5001/health 2>/dev/null)
if [ -n "$BACKEND_STATUS" ]; then
    echo -e "${GREEN}✓${NC} Backend responding on http://localhost:5001/health"
    echo "    Response: $BACKEND_STATUS"
else
    echo -e "${RED}✗${NC} Backend NOT responding on http://localhost:5001/health"
fi
echo ""

# 5. Check firewall
echo "5. Firewall Status"
echo "------------------"
if command -v ufw &> /dev/null && sudo ufw status 2>/dev/null | grep -q "Status: active"; then
    echo "UFW Firewall:"
    sudo ufw status | grep -E "80|5001" || echo "  No rules for ports 80/5001"
elif command -v firewall-cmd &> /dev/null && sudo firewall-cmd --state 2>/dev/null | grep -q running; then
    echo "firewalld:"
    sudo firewall-cmd --list-ports 2>/dev/null | grep -E "80|5001" || echo "  No rules for ports 80/5001"
else
    echo -e "${YELLOW}No common firewall detected or not active${NC}"
fi
echo ""

# 6. Access URLs
echo "=============================="
echo "📍 Access URLs"
echo "=============================="
echo ""

echo -e "${GREEN}From this server (localhost):${NC}"
echo "  http://localhost"
echo "  http://localhost:5001"
echo ""

echo -e "${GREEN}From same network (LAN):${NC}"
echo "$LOCAL_IPS" | head -1 | while read first_ip; do
    if [ -n "$first_ip" ]; then
        echo "  http://$first_ip"
        echo "  http://$first_ip:5001"
    fi
done
echo ""

if [ -n "$PUBLIC_IP" ]; then
    echo -e "${GREEN}From Internet (if ports are open):${NC}"
    echo "  http://$PUBLIC_IP"
    echo "  http://$PUBLIC_IP:5001"
    echo ""
fi

echo "=============================="
echo "💡 Tips"
echo "=============================="
echo ""
echo "If you can't access from outside:"
echo "  1. Check firewall rules (see above)"
echo "  2. If using cloud server, check Security Group settings"
echo "  3. Ensure ports 80 and 5001 are open"
echo ""
echo "Security recommendations:"
echo "  - Consider removing port 5001 from public access"
echo "  - Use HTTPS in production"
echo "  - Configure domain name instead of IP"
echo ""
