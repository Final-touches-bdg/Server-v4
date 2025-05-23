#!/usr/bin/env python3
"""
Main entry point for the iOS Terminal Server
Supports both traditional HTTP and WebSocket functionality
"""

import os
import sys
import eventlet
from flask_socketio import SocketIO

# Set eventlet as the async mode before importing Flask-SocketIO components
os.environ['EVENTLET_NO_GREENDNS'] = '1'  # Avoid DNS resolution issues
eventlet.monkey_patch()

def run_server():
    """Run the Flask app with Socket.IO support"""
    # Import the app and socketio instance here after monkey patching
    from flask_server import app, socketio
    
    # Get port from environment or use default
    port = int(os.environ.get('PORT', 3000))
    
    # Enable debug mode if requested
    debug = os.environ.get('DEBUG', 'False').lower() == 'true'
    
    print(f"Starting iOS Terminal Server with WebSocket support")
    print(f"Port: {port}")
    print(f"Debug mode: {debug}")
    print(f"WebSocket mode: {socketio.async_mode}")
    
    # Start the socketio server with allow_unsafe_werkzeug=True for production
    # This ensures that the server starts even in production environments
    socketio.run(
        app,
        host="0.0.0.0",
        port=port,
        debug=debug,
        use_reloader=debug,
        log_output=True,
        allow_unsafe_werkzeug=True  # Allow running in production
    )

if __name__ == "__main__":
    run_server()
