# FinEasy Landing Page

A high-converting, SEO-optimized landing page for FinEasy - Smart Business Finance Management.

## 🚀 Features

- **SEO Optimized**: Full meta tags, Open Graph, Twitter Cards, structured data (JSON-LD)
- **Mobile Responsive**: Works beautifully on all devices
- **Fast Loading**: Minimal dependencies, optimized CSS/JS
- **Accessible**: WCAG compliant, semantic HTML
- **Modern Design**: Clean, professional UI with smooth animations

## 📁 Project Structure

```
fineasy-landing/
├── index.html          # Main HTML file
├── styles.css          # All styles
├── script.js           # JavaScript functionality
├── manifest.json       # PWA manifest
├── robots.txt          # Search engine directives
├── sitemap.xml         # Sitemap for SEO
├── assets/             # Images and icons (create this folder)
│   ├── favicon-16x16.png
│   ├── favicon-32x32.png
│   ├── apple-touch-icon.png
│   ├── og-image.png    # 1200x630 for social sharing
│   └── icon-*.png      # PWA icons
└── README.md
```

## 🎨 Required Assets

Create an `assets/` folder and add:

1. **Favicons**: 16x16, 32x32 PNG
2. **Apple Touch Icon**: 180x180 PNG
3. **OG Image**: 1200x630 PNG (for social sharing)
4. **PWA Icons**: 72, 96, 128, 144, 152, 192, 384, 512 PNG

## 🌐 Hosting Options

### Option 1: Vercel (Recommended - Free)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
cd fineasy-landing
vercel
```

### Option 2: Netlify (Free)

1. Go to [netlify.com](https://netlify.com)
2. Drag & drop the `fineasy-landing` folder
3. Done!

Or use CLI:
```bash
npm i -g netlify-cli
netlify deploy --prod --dir=.
```

### Option 3: GitHub Pages (Free)

1. Create a new repo: `fineasy-landing`
2. Push this folder to the repo
3. Go to Settings → Pages → Select main branch
4. Your site will be at `https://yourusername.github.io/fineasy-landing`

### Option 4: Firebase Hosting

```bash
# Install Firebase CLI
npm i -g firebase-tools

# Login and init
firebase login
firebase init hosting

# Deploy
firebase deploy
```

### Option 5: Cloudflare Pages (Free)

1. Go to [pages.cloudflare.com](https://pages.cloudflare.com)
2. Connect your GitHub repo
3. Deploy!

## 🔧 Configuration

### Update URLs

Replace these placeholder URLs in `index.html`:

- `https://fineasy.tech/` → Your landing page domain
- `https://app.fineasy.tech` → Your main app URL
- `https://app.fineasy.tech/register` → Your registration URL

### Update Meta Tags

Edit the following in `index.html`:

```html
<meta property="og:url" content="YOUR_DOMAIN">
<link rel="canonical" href="YOUR_DOMAIN">
```

### Add Analytics

Add Google Analytics before `</head>`:

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

## 📊 SEO Checklist

- [x] Title tag (50-60 chars)
- [x] Meta description (150-160 chars)
- [x] Open Graph tags
- [x] Twitter Card tags
- [x] Canonical URL
- [x] Structured data (JSON-LD)
- [x] Semantic HTML (header, main, section, article, footer)
- [x] Alt text for images
- [x] Mobile responsive
- [x] Fast loading
- [x] robots.txt
- [x] sitemap.xml

## 🎯 Performance Tips

1. **Compress images** using TinyPNG or Squoosh
2. **Enable GZIP** on your hosting
3. **Use a CDN** (Cloudflare, etc.)
4. **Add caching headers**

## 📝 License

MIT License - Feel free to use and modify!
