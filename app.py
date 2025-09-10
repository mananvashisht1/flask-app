from flask import Flask, request, jsonify
import re

# Initialize the Flask application
app = Flask(__name__)

@app.route('/auth', methods=['POST'])
def authenticate():
    """
    Handles user authentication by validating email and password.
    
    The API expects a JSON body with 'email' and 'password' fields.
    - The email must be a valid @gmail.com address.
    - The password must be exactly 8 digits long.
    
    Returns:
    - 200 OK with a success message if credentials are valid.
    - 400 Bad Request with a specific error message for invalid credentials.
    """
    try:
        # Get the JSON data from the request
        data = request.json
        if not data:
            return jsonify({"message": "Request must be a valid JSON."}), 400
        
        email = data.get('email')
        password = data.get('password')

        # Check if email and password are provided
        if not email or not password:
            return jsonify({"message": "Email and password are required."}), 400

        # Validate email format: must be a valid @gmail.com address
        if not re.match(r'[^@]+@gmail\.com$', email):
            return jsonify({"message": "Invalid email format. Must be a valid @gmail.com address."}), 400

        # Validate password format: must be 8 digits long
        # We check if it's a string, if all characters are digits, and if the length is 8.
        if not (isinstance(password, str) and len(password) >= 8):
            return jsonify({"message": "Invalid password format. Must be 8 digits."}), 400

        # If all validations pass, authentication is successful
        return jsonify({"message": "Authentication successful"}), 200

    except Exception as e:
        # Handle unexpected errors
        app.logger.error(f"An error occurred: {e}")
        return jsonify({"message": "An internal server error occurred."}), 500

if __name__ == '__main__':
    # Run the application on all available network interfaces
    app.run(host='0.0.0.0', port=5000)
