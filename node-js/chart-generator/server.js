const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const path = require('path');
const app = express();
const port = process.env.PORT || 3001;

// Debug mode configuration
const DEBUG_MODE = process.env.DEBUG === 'true' || process.env.NODE_ENV === 'development';
const LOG_LEVEL = process.env.LOG_LEVEL || (DEBUG_MODE ? 'debug' : 'info');

// Logger utility
const logLevels = { debug: 0, info: 1, warn: 2, error: 3 };
const currentLogLevel = logLevels[LOG_LEVEL] ?? 1;

const logger = {
    levels: logLevels,
    currentLevel: currentLogLevel,
    
    debug: (...args) => {
        if (currentLogLevel <= 0) {
            console.log('[DEBUG]', new Date().toISOString(), ...args);
        }
    },
    info: (...args) => {
        if (currentLogLevel <= 1) {
            console.log('[INFO]', new Date().toISOString(), ...args);
        }
    },
    warn: (...args) => {
        if (currentLogLevel <= 2) {
            console.warn('[WARN]', new Date().toISOString(), ...args);
        }
    },
    error: (...args) => {
        if (currentLogLevel <= 3) {
            console.error('[ERROR]', new Date().toISOString(), ...args);
        }
    }
};
// Request logging middleware
app.use((req, res, next) => {
    const start = Date.now();
    logger.debug(`Incoming ${req.method} request to ${req.url}`);
    
    if (DEBUG_MODE && req.body && Object.keys(req.body).length > 0) {
        logger.debug('Request body:', JSON.stringify(req.body, null, 2));
    }
    
    // Log response when finished
    res.on('finish', () => {
        const duration = Date.now() - start;
        const logMethod = res.statusCode >= 400 ? 'error' : 'info';
        logger[logMethod](`${req.method} ${req.url} - ${res.statusCode} (${duration}ms)`);
    });
    
    next();
});

app.use(cors());
app.use(bodyParser.json({ limit: '10mb' }));
app.use(express.static('public'));

// Body parser error handling
app.use((err, req, res, next) => {
    if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
        logger.error('Invalid JSON in request body:', err.message);
        return res.status(400).json({ 
            success: false,
            error: 'Invalid JSON format',
            details: DEBUG_MODE ? err.message : undefined
        });
    }
    next(err);
});

// Health check endpoint
app.get('/health', (req, res) => {
    logger.debug('Health check requested');
    res.json({ 
        status: 'healthy',
        timestamp: new Date().toISOString(),
        debug_mode: DEBUG_MODE,
        log_level: LOG_LEVEL
    });
});

// API endpoint to generate chart
app.post('/generate', (req, res) => {
    try {
        logger.debug('Processing chart generation request');
        const chartConfig = req.body;
        
        // Basic validation
        if (!chartConfig || !chartConfig.series || !chartConfig.options) {
            logger.warn('Invalid chart configuration received');
            return res.status(400).json({ 
                success: false,
                error: 'Invalid chart configuration. Make sure to include "series" and "options" in your JSON.',
                received: DEBUG_MODE ? Object.keys(chartConfig || {}) : undefined
            });
        }
        
        // Additional validation
        if (!Array.isArray(chartConfig.series)) {
            logger.warn('Series is not an array');
            return res.status(400).json({
                success: false,
                error: 'Series must be an array',
                type_received: DEBUG_MODE ? typeof chartConfig.series : undefined
            });
        }
        
        if (typeof chartConfig.options !== 'object') {
            logger.warn('Options is not an object');
            return res.status(400).json({
                success: false,
                error: 'Options must be an object',
                type_received: DEBUG_MODE ? typeof chartConfig.options : undefined
            });
        }
        
        logger.info('Chart configuration validated successfully');
        logger.debug('Chart config:', JSON.stringify(chartConfig, null, 2));
        
        res.json({ 
            success: true,
            config: chartConfig
        });
    } catch (error) {
        logger.error('Error processing chart generation:', error.message);
        if (DEBUG_MODE) {
            logger.error('Stack trace:', error.stack);
        }
        
        res.status(500).json({ 
            success: false,
            error: error.message,
            stack: DEBUG_MODE ? error.stack : undefined
        });
    }
});

// Serve the main HTML file
app.get('*', (req, res) => {
    logger.debug(`Serving index.html for route: ${req.url}`);
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Global error handler (must be last)
app.use((err, req, res, next) => {
    logger.error('Unhandled error:', err.message);
    if (DEBUG_MODE) {
        logger.error('Stack trace:', err.stack);
    }
    
    res.status(err.status || 500).json({
        success: false,
        error: err.message || 'Internal server error',
        stack: DEBUG_MODE ? err.stack : undefined,
        path: req.url,
        method: req.method
    });
});

// Graceful shutdown handler
process.on('SIGTERM', () => {
    logger.info('SIGTERM signal received: closing HTTP server');
    server.close(() => {
        logger.info('HTTP server closed');
        process.exit(0);
    });
});

process.on('SIGINT', () => {
    logger.info('SIGINT signal received: closing HTTP server');
    server.close(() => {
        logger.info('HTTP server closed');
        process.exit(0);
    });
});

// Unhandled rejection handler
process.on('unhandledRejection', (reason, promise) => {
    logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
    if (DEBUG_MODE) {
        logger.error('Stack:', reason?.stack);
    }
});

const server = app.listen(port, () => {
    logger.info('='.repeat(60));
    logger.info(`ApexCharts Generator running at http://localhost:${port}`);
    logger.info(`- Edit the JSON on the left to customize your chart`);
    logger.info(`- See the chart update in real-time on the right`);
    logger.info('='.repeat(60));
    logger.info(`Environment: ${process.env.NODE_ENV || 'production'}`);
    logger.info(`Debug Mode: ${DEBUG_MODE ? 'ENABLED' : 'DISABLED'}`);
    logger.info(`Log Level: ${LOG_LEVEL}`);
    logger.info(`Health Check: http://localhost:${port}/health`);
    logger.info('='.repeat(60));
    
    if (DEBUG_MODE) {
        logger.debug('Debug mode is active - verbose logging enabled');
        logger.debug('Available endpoints:');
        logger.debug('  GET  /health - Health check');
        logger.debug('  POST /generate - Generate chart');
        logger.debug('  GET  /* - Serve index.html');
    }
});
