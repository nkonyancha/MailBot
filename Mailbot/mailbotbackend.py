from flask import Flask, request, jsonify

import base64
from email.mime.text import MIMEText
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from requests import HTTPError
from flask_cors import CORS
app = Flask(__name__)
CORS(app)
SCOPES=[
    "https://www.googleapis.com/auth/gmail.send"
]
flow=InstalledAppFlow.from_client_secrets_file('client_secret.json',SCOPES)
creds=flow.run_local_server(port=0)
service=build('gmail','v1',credentials=creds)

@app.route('/send-email', methods=['POST'])
def sendemail():

    print("Received request:", request.json)
    try:
        data = request.json
        recipients = data['to']
        subject = data['subject']
        body = data['body']
        image=data['file']
        for recipient in recipients:
            messege=MIMEText(body)
            messege['to']=recipient
            messege['subject']=subject
            messege['attachments']=image
            encoded_message = base64.urlsafe_b64encode(messege.as_bytes()).decode()
            create_message={'raw': encoded_message}
            sentmessege=(service.users().messages().send(userId='me',body=create_message).execute())

        return jsonify({'messages sent twin':sentmessege['id']})
    except HTTPError as err:
        return jsonify({"error":str(err)}),500
        messege=None

if __name__ == '__main__':
    app.run(host='0.0.0.0',port=5000,debug=True)