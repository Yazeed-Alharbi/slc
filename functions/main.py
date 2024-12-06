from firebase_functions import https_fn
from firebase_admin import initialize_app
from openai import OpenAI

initialize_app()

client = OpenAI(api_key="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")  # Replace with your actual API key

@https_fn.on_request()
def process_text(req: https_fn.Request) -> https_fn.Response:
    try:

        data = req.get_json(silent=True)
        if not data or "text" not in data:
            return https_fn.Response(
                '{"error": "Invalid request. \'text\' field is required."}',
                mimetype="application/json",
                status=400
            )

        user_input = data["text"]
        completion = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "user", "content": user_input},
            ],
        )

        assistant_reply = completion.choices[0].message.content

        # Return the response to the client
        return https_fn.Response(
            f'{{"reply": "{assistant_reply}"}}',
            mimetype="application/json",
            status=200
        )

    except Exception as e:
        return https_fn.Response(
            f'{{"error": "An error occurred: {str(e)}"}}',
            mimetype="application/json",
            status=500
        )
