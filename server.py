"""
SAP ABAP Project Live Runner & Server
Launches the interactive SAP GUI web simulator for ZA16_LIBRARY_MANAGEMENT
"""
import http.server
import socketserver
import webbrowser
import os
import sys

PORT = 8085
DIRECTORY = os.path.dirname(os.path.abspath(__file__))

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

def run():
    os.chdir(DIRECTORY)
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        url = f"http://localhost:{PORT}/index.html"
        print("=" * 65)
        print("  SAP GUI SIMULATOR - LIBRARY MANAGEMENT SYSTEM (ABAP)")
        print("=" * 65)
        print(f"  Server running at: {url}")
        print("  Press Ctrl+C to stop the server.")
        print("=" * 65)
        webbrowser.open(url)
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nShutting down SAP Simulator Server...")
            httpd.shutdown()

if __name__ == "__main__":
    run()
