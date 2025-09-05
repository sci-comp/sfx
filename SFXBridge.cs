using Core;
using Godot;

namespace Audio
{
    /// <summary>
    /// Autoload singleton accessible at /root/SFXBridge
    /// </summary>
    public partial class SFXBridge : Node
    {
        private CameraBridge cameraBridge;
        private Node sfxNode;
        private Node sfx2dNode;

        public override void _Ready()
        {
            cameraBridge = GetNode<CameraBridge>("/root/CameraBridge");
            sfxNode = GetNode("/root/SFX");
            sfx2dNode = GetNode("/root/SFX2D");
        }

        public void Play(string soundGroupName)
        {
            sfxNode?.Call("play", soundGroupName);
        }

        public void PlaySound(string soundGroupName)
        {
            PlaySound(soundGroupName, cameraBridge.MainCamera.GlobalPosition);
        }

        public void PlaySound(string soundGroupName, Vector3 location)
        {
            sfxNode?.Call("play_sound", soundGroupName, location);
        }

        public void Play2D(string name)
        {
            sfx2dNode?.Call("play_sound", name);
        }

        public void SetMainCamera(Camera3D camera)
        {
            sfxNode?.Call("set_main_camera", camera);
        }

    }

}

