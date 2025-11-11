import gradio as gr
import requests

# Define the assistant UI
def chat_with_agent(prompt):
    response = requests.post("http://localhost:8000/act", json={"prompt": prompt})
    return response.json().get("response", "No response.")

iface = gr.Interface(fn=chat_with_agent, 
                     inputs=gr.Textbox(label="Ask me anything..."), 
                     outputs="text", 
                     theme="dark", 
                     title="Helix-Ω Assistant")

iface.launch(server_name="0.0.0.0", server_port=3000)
