# Multi-stage build for MiroFish Backend
FROM python:3.11-slim as builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy dependency files
COPY pyproject.toml uv.lock ./
COPY requirements.txt ./

# Install uv package manager and Python dependencies in one step
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    /root/.cargo/bin/uv pip install --system -r requirements.txt

# Production stage
FROM python:3.11-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN useradd -m -u 1000 mirofish && \
    mkdir -p /app /app/uploads /app/logs && \
    chown -R mirofish:mirofish /app

# Set working directory
WORKDIR /app

# Copy Python packages from builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy application code
COPY --chown=mirofish:mirofish app/ ./app/
COPY --chown=mirofish:mirofish run.py ./

# Create necessary directories with proper permissions
RUN mkdir -p /app/uploads/simulations /app/logs && \
    chown -R mirofish:mirofish /app

# Switch to non-root user
USER mirofish

# Expose port
EXPOSE 5001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5001/health')" || exit 1

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    FLASK_HOST=0.0.0.0 \
    FLASK_PORT=5001

# Run the application
CMD ["python", "run.py"]
