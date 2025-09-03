<script>
	import { onMount } from 'svelte';
	import Bubble from './Bubble.svelte';
	import { fade, fly } from 'svelte/transition';

	let { commentData, direction = 'left', delay = { in: 0, out: 0 } } = $props();
</script>

{#each commentData as comment, index}
	<div
		class="comment-item"
		in:fly|global={{ y: 500, duration: 400, delay: 50 * index + delay.in }}
		out:fly|global={{ y: -500, duration: 200, delay: 50 * index + delay.out }}
		style="
        top: {comment.position.top}; 
        left: {comment.position.left}; 
      "
	>
		<Bubble color={comment.position.color || getCSSVar('--color-theme-light')} {direction}>
			{comment.text}
		</Bubble>
	</div>
{/each}

<style lang="scss">
	.comment-item {
		position: absolute;
		font-size: clamp(0.9rem, 3rem, 2rem);
		color: $color-theme-light;
		line-height: 1.3;
		padding: 0.5rem;

		&.fade-in {
			opacity: 1;
			transform: scale(1) translateY(0);
		}
	}
</style>
