const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const path = require('path');
const app = express();
const port = 3001; // Changed to 3001 to avoid conflict
app.use(cors());
app.use(bodyParser.json());
app.use(express.static('public'));

// API endpoint to generate chart
app.post('/generate', (req, res) => {
    try {
        const chartConfig = req.body;
        // Basic validation
        if (!chartConfig || !chartConfig.series || !chartConfig.options) {
            return res.status(400).json({ error: 'Invalid chart configuration. Make sure to include "series" and "options" in your JSON.' });
        }
        res.json({ 
            success: true,
            config: chartConfig
        });
    } catch (error) {
        res.status(500).json({ 
            success: false,
            error: error.message 
        });
    }
});

// Serve the main HTML file
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(port, () => {
    console.log(`ApexCharts Generator running at http://localhost:${port}`);
    console.log(`- Edit the JSON on the left to customize your chart`);
    console.log(`- See the chart update in real-time on the right`);
});
