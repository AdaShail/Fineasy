#!/bin/bash

# Build script with environment variables
# Usage: ./build_with_env.sh [development|staging|production]

ENV=${1:-development}

echo "🚀 Building for environment: $ENV"

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "⚠️  .env file not found!"
    exit 1
fi

# Build based on environment
case $ENV in
    development)
        echo "Building development APK..."
        flutter build apk --debug \
            --dart-define=SUPABASE_URL="$SUPABASE_URL" \
            --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
            --dart-define=AI_BACKEND_URL="$AI_BACKEND_URL" \
            --dart-define=GEMINI_API_KEY="$GEMINI_API_KEY" \
            --dart-define=PRODUCTION=false
        ;;
    
    staging)
        echo "Building staging APK..."
        flutter build apk --release \
            --dart-define=SUPABASE_URL="$SUPABASE_URL" \
            --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
            --dart-define=AI_BACKEND_URL="$AI_BACKEND_URL" \
            --dart-define=GEMINI_API_KEY="$GEMINI_API_KEY" \
            --dart-define=PRODUCTION=false
        ;;
    
    production)
        echo "Building production AAB..."
        flutter build appbundle --release \
            --dart-define=SUPABASE_URL="$SUPABASE_URL" \
            --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
            --dart-define=AI_BACKEND_URL="$AI_BACKEND_URL" \
            --dart-define=GEMINI_API_KEY="$GEMINI_API_KEY" \
            --dart-define=PRODUCTION=true \
            --dart-define=ENABLE_ANALYTICS=true \
            --dart-define=ENABLE_CRASH_REPORTING=true
        ;;
    
    *)
        echo "❌ Invalid environment: $ENV"
        echo "Usage: ./build_with_env.sh [development|staging|production]"
        exit 1
        ;;
esac

echo ""
echo "✅ Build complete!"
