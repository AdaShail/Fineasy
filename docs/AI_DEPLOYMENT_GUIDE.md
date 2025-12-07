# AI Deployment Guide

## Overview

This guide covers the deployment and maintenance of the AI-powered business intelligence system for the FinEasy application.

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │  AI Backend     │    │   Supabase      │
│                 │    │  (Python)       │    │   Database      │
│  - AI Providers │◄──►│  - FastAPI      │◄──►│  - PostgreSQL   │
│  - AI Widgets   │    │  - ML Services  │    │  - Auth         │
│  - AI Screens   │    │  - Redis Cache  │    │  - Storage      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Prerequisites

### System Requirements
- Python 3.9+
- Redis 6.0+
- Docker and Docker Compose
- Kubernetes (for production)
- Minimum 4GB RAM
- 20GB storage space

### Dependencies
- FastAPI
- Supabase Python client
- scikit-learn
- spaCy NLP models
- Redis client
- Prometheus (monitoring)

## Deployment Steps

### 1. Environment Setup

**Create environment files:**

```bash
# ai-backend/.env
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_KEY=your_service_key
SUPABASE_ANON_KEY=your_anon_key

# AI Service Configuration
OPENAI_API_KEY=your_openai_key
HUGGINGFACE_API_KEY=your_hf_key

# GST API Configuration
GST_API_URL=https://api.gst.gov.in
GST_API_KEY=your_gst_api_key

# Redis Configuration
REDIS_URL=redis://localhost:6379

# Application Configuration
ENVIRONMENT=production
LOG_LEVEL=INFO
API_VERSION=v1
```

### 2. Database Setup

**Run database migrations:**

```bash
# Apply AI schema extensions
psql -h your_supabase_host -U postgres -d postgres -f schema/ai_extensions.sql

# Apply feature flags schema
psql -h your_supabase_host -U postgres -d postgres -f schema/feature_flags.sql

# Apply usage analytics schema
psql -h your_supabase_host -U postgres -d postgres -f schema/usage_analytics.sql
```

### 3. Docker Deployment

**Build and deploy with Docker Compose:**

```bash
# Development deployment
docker-compose up -d

# Production deployment
docker-compose -f docker-compose.prod.yml up -d
```

**Docker Compose Configuration:**

```yaml
version: '3.8'
services:
  ai-backend:
    build: .
    ports:
      - "8000:8000"
    environment:
      - SUPABASE_URL=${SUPABASE_URL}
      - SUPABASE_SERVICE_KEY=${SUPABASE_SERVICE_KEY}
      - REDIS_URL=redis://redis:6379
    volumes:
      - ./ml_models:/app/ml_models
    depends_on:
      - redis
      
  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
      
volumes:
  redis_data:
```

### 4. Kubernetes Deployment

**Apply Kubernetes manifests:**

```bash
# Deploy AI backend
kubectl apply -f k8s/deployment.yaml

# Deploy Redis
kubectl apply -f k8s/redis.yaml

# Apply monitoring
kubectl apply -f monitoring/
```

**Kubernetes Deployment Configuration:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ai-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ai-backend
  template:
    metadata:
      labels:
        app: ai-backend
    spec:
      containers:
      - name: ai-backend
        image: fineasy/ai-backend:latest
        ports:
        - containerPort: 8000
        env:
        - name: SUPABASE_URL
          valueFrom:
            secretKeyRef:
              name: ai-secrets
              key: supabase-url
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
```

### 5. Flutter App Configuration

**Update Flutter environment:**

```dart
// lib/config/ai_config.dart
class AIConfig {
  static const String baseUrl = String.fromEnvironment(
    'AI_BACKEND_URL',
    defaultValue: 'https://your-ai-backend.com',
  );
  static const int timeoutSeconds = 30;
  static const bool enableFraudAlerts = true;
  static const bool enablePredictiveInsights = true;
}
```

## Monitoring and Observability

### 1. Prometheus Metrics

**Configure Prometheus:**

```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'ai-backend'
    static_configs:
      - targets: ['ai-backend:8000']
    metrics_path: '/metrics'
```

### 2. Grafana Dashboards

**Key metrics to monitor:**
- AI service response times
- ML model accuracy metrics
- Cache hit rates
- Error rates by service
- Resource utilization

### 3. Logging

**Configure structured logging:**

```python
# logging.conf
[loggers]
keys=root,ai_backend

[handlers]
keys=consoleHandler,fileHandler

[formatters]
keys=jsonFormatter

[logger_root]
level=INFO
handlers=consoleHandler,fileHandler

[logger_ai_backend]
level=DEBUG
handlers=consoleHandler,fileHandler
qualname=ai_backend
propagate=0

[handler_consoleHandler]
class=StreamHandler
level=INFO
formatter=jsonFormatter
args=(sys.stdout,)

[handler_fileHandler]
class=FileHandler
level=DEBUG
formatter=jsonFormatter
args=('logs/ai_backend.log',)

[formatter_jsonFormatter]
format={"timestamp": "%(asctime)s", "level": "%(levelname)s", "module": "%(name)s", "message": "%(message)s"}
```

## Security Configuration

### 1. Authentication

**Configure JWT authentication:**

```python
# app/utils/auth.py
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")
JWT_ALGORITHM = "HS256"
JWT_EXPIRATION_HOURS = 24
```

### 2. Data Encryption

**Configure encryption for sensitive data:**

```python
# app/utils/encryption.py
ENCRYPTION_KEY = os.getenv("ENCRYPTION_KEY")
FERNET_KEY = Fernet.generate_key()
```

### 3. Network Security

**Configure HTTPS and CORS:**

```python
# app/main.py
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://your-flutter-app.com"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)
```

## Performance Optimization

### 1. Caching Strategy

**Redis caching configuration:**

```python
# Cache TTL settings
CACHE_TTL = {
    "insights": 24 * 3600,  # 24 hours
    "fraud_analysis": 6 * 3600,  # 6 hours
    "compliance_check": 12 * 3600,  # 12 hours
    "ml_models": 7 * 24 * 3600,  # 7 days
}
```

### 2. Database Optimization

**Create performance indexes:**

```sql
-- Indexes for AI analysis results
CREATE INDEX idx_ai_analysis_business_type ON ai_analysis_results(business_id, analysis_type);
CREATE INDEX idx_ai_analysis_created ON ai_analysis_results(created_at);

-- Indexes for fraud alerts
CREATE INDEX idx_fraud_alerts_business_status ON fraud_alerts(business_id, status);
CREATE INDEX idx_fraud_alerts_created ON fraud_alerts(created_at);

-- Indexes for business insights
CREATE INDEX idx_insights_business_valid ON business_insights(business_id, valid_until);
CREATE INDEX idx_insights_type ON business_insights(insight_type);
```

### 3. Resource Management

**Configure resource limits:**

```yaml
# k8s/deployment.yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "250m"
  limits:
    memory: "2Gi"
    cpu: "1000m"
```

## Backup and Recovery

### 1. Database Backups

**Automated backup script:**

```bash
#!/bin/bash
# scripts/backup_ai_data.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/ai_data"

# Backup AI-specific tables
pg_dump -h $SUPABASE_HOST -U postgres -d postgres \
  -t ai_analysis_results \
  -t fraud_alerts \
  -t business_insights \
  -t ml_models \
  > $BACKUP_DIR/ai_data_$DATE.sql

# Backup ML models
tar -czf $BACKUP_DIR/ml_models_$DATE.tar.gz ml_models/

echo "Backup completed: $DATE"
```

### 2. Disaster Recovery

**Recovery procedures:**

1. **Database Recovery:**
   ```bash
   psql -h $SUPABASE_HOST -U postgres -d postgres < backup_file.sql
   ```

2. **ML Model Recovery:**
   ```bash
   tar -xzf ml_models_backup.tar.gz -C ml_models/
   ```

3. **Service Recovery:**
   ```bash
   kubectl rollout restart deployment/ai-backend
   ```

## Scaling Considerations

### 1. Horizontal Scaling

**Auto-scaling configuration:**

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ai-backend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ai-backend
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### 2. Load Balancing

**Configure load balancer:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ai-backend-service
spec:
  selector:
    app: ai-backend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8000
  type: LoadBalancer
```

## Maintenance Procedures

### 1. Regular Maintenance Tasks

**Weekly tasks:**
- Review AI accuracy metrics
- Clean up old analysis results
- Update ML models if needed
- Check resource utilization

**Monthly tasks:**
- Backup ML models
- Review and optimize database queries
- Update dependencies
- Performance testing

### 2. ML Model Updates

**Model update procedure:**

```bash
# Download new model
wget https://models.example.com/fraud_detection_v2.pkl

# Validate model
python scripts/validate_model.py fraud_detection_v2.pkl

# Deploy model
kubectl create configmap ml-models --from-file=ml_models/

# Restart services
kubectl rollout restart deployment/ai-backend
```

### 3. Health Checks

**Automated health monitoring:**

```python
# app/api/health.py
@router.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow(),
        "services": {
            "database": await check_database_health(),
            "redis": await check_redis_health(),
            "ml_models": await check_ml_models_health(),
        }
    }
```

## Troubleshooting

### Common Issues

1. **High Memory Usage:**
   - Check ML model cache size
   - Review memory limits
   - Optimize model loading

2. **Slow Response Times:**
   - Check Redis cache hit rates
   - Review database query performance
   - Monitor network latency

3. **ML Model Errors:**
   - Validate model files
   - Check model compatibility
   - Review training data quality

### Debug Commands

```bash
# Check service logs
kubectl logs -f deployment/ai-backend

# Check resource usage
kubectl top pods

# Test API endpoints
curl -X GET "https://your-ai-backend.com/health"

# Check Redis connection
redis-cli ping

# Validate database connection
psql -h $SUPABASE_HOST -U postgres -c "SELECT 1"
```

## Support and Documentation

### Internal Documentation
- API documentation: `/docs` endpoint
- Model documentation: `ml_models/README.md`
- Database schema: `schema/README.md`

### External Resources
- FastAPI documentation
- Supabase documentation
- scikit-learn documentation
- Redis documentation

### Contact Information
- Technical Lead: [email]
- DevOps Team: [email]
- On-call Support: [phone/slack]

---

This deployment guide should be updated as the system evolves and new features are added.