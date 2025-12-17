// DOM Elements
const urlInput = document.getElementById('urlInput');
const generateBtn = document.getElementById('generateBtn');
const qrSection = document.getElementById('qrSection');
const qrCanvas = document.getElementById('qrCanvas');
const downloadPngBtn = document.getElementById('downloadPng');
const downloadPdfBtn = document.getElementById('downloadPdf');
const errorMessage = document.getElementById('errorMessage');

// QR Code instance
let qrCode = null;
let currentUrl = '';

// Initialize event listeners
function init() {
    generateBtn.addEventListener('click', generateQRCode);
    downloadPngBtn.addEventListener('click', downloadAsPNG);
    downloadPdfBtn.addEventListener('click', downloadAsPDF);
    
    // Allow Enter key to generate QR code
    urlInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            generateQRCode();
        }
    });
}

// Validate URL
function isValidUrl(string) {
    try {
        const url = new URL(string);
        return url.protocol === 'http:' || url.protocol === 'https:';
    } catch (_) {
        return false;
    }
}

// Show error message
function showError(message) {
    errorMessage.textContent = message;
    errorMessage.classList.remove('hidden');
    qrSection.classList.add('hidden');
    
    setTimeout(() => {
        errorMessage.classList.add('hidden');
    }, 5000);
}

// Generate QR Code
function generateQRCode() {
    const url = urlInput.value.trim();
    
    // Validation
    if (!url) {
        showError('Please enter a URL');
        return;
    }
    
    if (!isValidUrl(url)) {
        showError('Please enter a valid URL (must start with http:// or https://)');
        return;
    }
    
    // Clear previous QR code
    while (qrCanvas.firstChild) {
        qrCanvas.removeChild(qrCanvas.firstChild);
    }
    
    // Show QR section immediately
    qrSection.style.display = 'block';
    qrSection.classList.remove('hidden');
    errorMessage.classList.add('hidden');
    
    // Create a new canvas element
    const canvas = document.createElement('canvas');
    canvas.id = 'qr-canvas';
    qrCanvas.appendChild(canvas);
    
    // Generate new QR code
    try {
        qrCode = new QRCode(canvas, {
            text: url,
            width: 256,
            height: 256,
            colorDark: '#000000',
            colorLight: '#ffffff',
            correctLevel: QRCode.CorrectLevel.H
        });
        
        currentUrl = url;
        
        // Force a reflow to ensure the transition works
        void qrSection.offsetHeight;
        
    } catch (error) {
        showError('Error generating QR code. Please try again.');
        console.error('QR Generation Error:', error);
    }
}

// Download as PNG
function downloadAsPNG() {
    try {
        // Get the canvas element created by QRCode.js
        const canvas = qrCanvas.querySelector('canvas');
        
        if (!canvas) {
            showError('No QR code to download');
            return;
        }
        
        // Convert canvas to blob and download
        canvas.toBlob((blob) => {
            const url = URL.createObjectURL(blob);
            const link = document.createElement('a');
            link.href = url;
            link.download = `qrcode-${Date.now()}.png`;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            URL.revokeObjectURL(url);
        });
        
    } catch (error) {
        showError('Error downloading PNG. Please try again.');
        console.error('PNG Download Error:', error);
    }
}

// Download as PDF
function downloadAsPDF() {
    try {
        // Get the canvas element created by QRCode.js
        const canvas = qrCanvas.querySelector('canvas');
        
        if (!canvas) {
            showError('No QR code to download');
            return;
        }
        
        // Get image data from canvas
        const imgData = canvas.toDataURL('image/png');
        
        // Create PDF using jsPDF
        const { jsPDF } = window.jspdf;
        const pdf = new jsPDF({
            orientation: 'portrait',
            unit: 'mm',
            format: 'a4'
        });
        
        // Calculate dimensions to center the QR code
        const pageWidth = pdf.internal.pageSize.getWidth();
        const pageHeight = pdf.internal.pageSize.getHeight();
        const qrSize = 80; // Size in mm
        const x = (pageWidth - qrSize) / 2;
        const y = 40;
        
        // Add title
        pdf.setFontSize(20);
        pdf.text('QR Code', pageWidth / 2, 20, { align: 'center' });
        
        // Add QR code image
        pdf.addImage(imgData, 'PNG', x, y, qrSize, qrSize);
        
        // Add URL text below QR code
        pdf.setFontSize(10);
        const urlText = currentUrl.length > 60 ? currentUrl.substring(0, 60) + '...' : currentUrl;
        pdf.text(urlText, pageWidth / 2, y + qrSize + 15, { align: 'center' });
        
        // Add generation date
        pdf.setFontSize(8);
        pdf.setTextColor(128);
        const date = new Date().toLocaleDateString();
        pdf.text(`Generated on: ${date}`, pageWidth / 2, pageHeight - 10, { align: 'center' });
        
        // Download the PDF
        pdf.save(`qrcode-${Date.now()}.pdf`);
        
    } catch (error) {
        showError('Error downloading PDF. Please try again.');
        console.error('PDF Download Error:', error);
    }
}

// Initialize the application
init();

// Debug: Log when the script loads
console.log('QR Code Generator initialized');
