<script>
	import { onMount } from 'svelte';
	import { gsap } from 'gsap';
	import { getCSSVar } from '$lib/helpers/getCSSVar';

	let { commentData, progress = 0, startProgress = 0, endProgress = 1 } = $props();
	let commentElements = [];

	// Calculate individual comment progress based on overall progress
	let commentProgress = $derived(() => {
		if (progress < startProgress) return 0;
		if (progress > endProgress) return 1;
		return (progress - startProgress) / (endProgress - startProgress);
	});

	// Set initial states when elements are available
	$effect(() => {
		commentElements.forEach((element, index) => {
			if (element) {
				const comment = commentData[index];
				const initialScale = comment.position.scale || 0.3;
				gsap.set(element, {
					scale: initialScale * 0.5, // Start at half the target scale
					opacity: 0,
					y: 100
				});
			}
		});
	});

	// Animate comments based on progress
	$effect(() => {
		const currentProgress = commentProgress();

		commentElements.forEach((element, index) => {
			if (element) {
				const comment = commentData[index];
				const targetScale = comment.position.scale || 1.0;

				// Stagger the animation based on index
				const individualProgress = Math.max(0, Math.min(1, (currentProgress - index * 0.1) / 0.3));

				// Scale and opacity animation using comment's scale property
				const initialScale = targetScale * 0.5; // Half of target scale
				const scale = initialScale + individualProgress * (targetScale - initialScale);
				const opacity = individualProgress;
				const y = (1 - individualProgress) * 100; // Start 100px below, move to 0

				gsap.to(element, {
					scale: scale,
					opacity: opacity,
					y: y,
					duration: 0.1,
					ease: 'power2.out'
				});
			}
		});
	});
</script>

{#each commentData as comment, index}
	<div
		class="comment-item"
		bind:this={commentElements[index]}
		style="
        top: {comment.position.top}; 
        left: {comment.position.left};
      "
	>
		<img src={`/assets/comments/${comment.name}`} alt={comment.text} />
	</div>
{/each}

<style lang="scss">
	.comment-item {
		position: absolute;
		font-size: clamp(0.9rem, 3rem, 2rem);
		color: $color-theme-light;
		line-height: 1.3;
		padding: 0.5rem;
		will-change: transform, opacity;
		transform-origin: center center;
		opacity: 0.8; // Fallback visibility
		transform: scale(0.8); // Fallback scale

		width: 300px;

		@include mq('mobile', 'max') {
			width: 150px;
			margin-left: -5vw;
		}

		img {
			opacity: 0.5;
		}

		&.fade-in {
			opacity: 1;
			transform: scale(1) translateY(0);
		}
	}
</style>
