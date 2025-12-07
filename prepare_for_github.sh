#!/bin/bash

echo "🧹 Cleaning project for GitHub..."

# Clean Flutter
echo "Cleaning Flutter build artifacts..."
flutter clean

# Remove build directories
echo "Removing build directories..."
rm -rf build/
rm -rf .dart_tool/
rm -rf android/build/
rm -rf android/app/build/
rm -rf android/.gradle/
rm -rf ios/build/
rm -rf macos/build/
rm -rf linux/build/
rm -rf windows/build/

# Clean AI backend
echo "Cleaning AI backend..."
cd ai-backend
rm -rf venv/
rm -rf __pycache__/
rm -rf .pytest_cache/
rm -rf *.egg-info/
rm -rf dist/
rm -rf build/
cd ..

# Create .env.example if it doesn't exist
if [ ! -f .env.example ]; then
    echo "Creating .env.example..."
    cat > .env.example << 'EOF'
# Supabase Configuration
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here

# AI Backend
AI_BACKEND_URL=your_ai_backend_url_here
GEMINI_API_KEY=your_gemini_api_key_here

# WhatsApp Business API (Optional)
WHATSAPP_BUSINESS_PHONE_ID=your_phone_id_here
WHATSAPP_ACCESS_TOKEN=your_access_token_here
EOF
fi

# Check repository size
echo ""
echo "📊 Repository size:"
du -sh .

echo ""
echo "✅ Project cleaned and ready for GitHub!"
echo ""
echo "Next steps:"
echo "1. Review .env.example and ensure no secrets"
echo "2. git add ."
echo "3. git commit -m 'Production ready'"
echo "4. git push origin main"
