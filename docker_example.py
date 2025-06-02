#!/usr/bin/env python3
"""
Example of using CUA in Docker for Linux environments
"""

import asyncio
from computer import Computer
from agent import ComputerAgent, LLM, AgentLoop, LLMProvider

async def main():
    # For Docker Linux environment, we can only use Linux OS type
    # Note: macOS VMs require running on actual macOS hardware with Lume
    
    print("🚀 Starting CUA Docker Example...")
    
    # Example 1: Using Computer directly (for Linux container)
    try:
        # Create a Linux computer instance
        # In Docker, this would control the container itself
        computer = Computer(
            os_type="linux",
            display="1024x768",
            memory="4GB",
            cpu="2"
        )
        
        print("✅ Computer instance created")
        
        # Note: In a real Docker container, you'd need:
        # 1. X11 or Xvfb for display
        # 2. VNC server for remote access
        # 3. Proper permissions for automation
        
    except Exception as e:
        print(f"❌ Error creating computer: {e}")
    
    # Example 2: Using an AI Agent (requires API keys)
    try:
        # You can use various AI providers
        # Make sure to set the appropriate API keys as environment variables
        
        # Example with Ollama (local models)
        agent = ComputerAgent(
            computer=computer,
            loop=AgentLoop.OMNI,
            model=LLM(
                provider=LLMProvider.OLLAMA,
                name="llama2"  # or any model you have in Ollama
            )
        )
        
        print("✅ Agent created with Ollama")
        
        # Example task
        # await agent.run("Open a terminal and show system information")
        
    except Exception as e:
        print(f"❌ Error creating agent: {e}")
    
    # Example 3: Using cloud providers (requires API keys)
    """
    # OpenAI example (requires OPENAI_API_KEY)
    agent = ComputerAgent(
        computer=computer,
        loop=AgentLoop.OPENAI,
        model=LLM(provider=LLMProvider.OPENAI)
    )
    
    # Anthropic example (requires ANTHROPIC_API_KEY)
    agent = ComputerAgent(
        computer=computer,
        loop=AgentLoop.ANTHROPIC,
        model=LLM(provider=LLMProvider.ANTHROPIC)
    )
    """
    
    print("\n📝 Docker Deployment Notes:")
    print("- This container can only run Linux environments")
    print("- For macOS VMs, you need to run on actual Mac hardware with Lume")
    print("- Add Xvfb for headless GUI operations")
    print("- Use VNC for remote desktop access")
    print("- Mount volumes for persistent storage")

if __name__ == "__main__":
    print("CUA Docker Example")
    print("==================")
    asyncio.run(main())
