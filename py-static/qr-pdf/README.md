# QR Code Generator Web App

A beautiful, modern web application that **generates QR codes from URLs** and allows downloading them as PNG or PDF files. 

Built with pure client-side rendering, **CSR** - no server required!

## Features

✨ **Modern UI/UX** - Beautiful gradient design with smooth animations  
🔗 **URL Validation** - Ensures valid URLs before generating QR codes  
📱 **Responsive Design** - Works perfectly on desktop, tablet, and mobile  
📥 **PNG Download** - Download QR codes as high-quality PNG images  
📄 **PDF Download** - Download QR codes as formatted PDF documents  
⚡ **Client-Side Only** - No server needed, runs entirely in the browser  
🎨 **High Quality** - Generates 256x256px QR codes with high error correction

## Technologies Used

- **HTML5** - Semantic markup
- **CSS3** - Modern styling with gradients and animations
- **Vanilla JavaScript** - No frameworks, pure JS
- **QRCode.js** - QR code generation library
- **jsPDF** - PDF generation library

## How to Use

1. **Open the Application**
   - Simply open `index.html` in any modern web browser
   - Or use a local server for best results

2. **Generate QR Code**
   - Enter a valid URL (must start with http:// or https://)
   - Click "Generate QR Code" or press Enter
   - Your QR code will appear instantly

3. **Download**
   - Click "Download PNG" to save as an image file
   - Click "Download PDF" to save as a formatted PDF document

## Running the Application

### Option 1: Direct File Open

```bash
# Simply open the file in your browser
open index.html  # macOS
xdg-open index.html  # Linux
start index.html  # Windows
```

### Option 2: Local Server (Recommended)

```bash
# Using Python 3
python3 -m http.server 8000

# Using Python 2
python -m SimpleHTTPServer 8000

# Using Node.js (npx)
npx http-server -p 8000

# Using PHP
php -S localhost:8000
```

Then open your browser and navigate to `http://localhost:8000`

![alt text](qr-sample.png)

## File Structure

```
qr-pdf/
├── index.html      # Main HTML structure
├── styles.css      # All styling and animations
├── app.js          # QR generation and download logic
└── README.md       # This file
```

## Browser Compatibility

- ✅ Chrome/Edge (latest)
- ✅ Firefox (latest)
- ✅ Safari (latest)
- ✅ Opera (latest)

## Features in Detail

### QR Code Generation
- Uses QRCode.js library for reliable QR code generation
- High error correction level (Level H - 30% recovery)
- 256x256 pixel resolution for optimal scanning

### PNG Download
- Direct canvas-to-blob conversion
- Maintains full quality
- Automatic filename with timestamp

### PDF Download
- A4 format, portrait orientation
- Centered QR code with title
- Includes original URL and generation date
- Professional formatting

## Customization

You can easily customize the app by modifying:

- **Colors**: Edit the gradient values in `styles.css`
- **QR Size**: Change `width` and `height` in `app.js` (line 57-58)
- **PDF Layout**: Modify dimensions in the `downloadAsPDF()` function

## Security Notes

- All processing happens client-side
- No data is sent to any server
- URLs are validated before processing
- Safe to use with sensitive links

## License

Free to use and modify for personal and commercial projects.

## Credits

Built with ❤️ using:
- [QRCode.js](https://davidshimjs.github.io/qrcodejs/)
- [jsPDF](https://github.com/parallax/jsPDF)

---

Enjoy generating QR codes! 🎉
