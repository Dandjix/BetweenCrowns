namespace SeeThrough
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    [DisallowMultipleComponent]
    public class VisibleThrough : MonoBehaviour
    {
        public LayerMask Mask { get => SeeThroughManager.Instance.Mask; }

        [SerializeField] private VisibleThroughPreset preset;
        public VisibleThroughPreset Preset { get => preset; set => preset = value; }

        public int Priority { get => preset.Priority; }
        public float Size { get => preset.Size; }
        public float Opacity { get => preset.Opacity; }
        public float Smoothness { get => preset.Smoothness; }
        public float TimeToVisible { get => preset.TimeToVisible; }


        private float visible = 0;
        public float Visible
        {
            get => visible;
            set
            {
                visible = value;
                if (visible <= 0)
                {
                    SeeThroughManager.Instance.TryRemove(this);
                }
                else
                {
                    SeeThroughManager.Instance.TryAdd(this);
                }
            }
        }
    }
}

