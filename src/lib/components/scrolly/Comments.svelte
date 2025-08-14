<script>
	import { onMount } from 'svelte';
	import Bubble from './Bubble.svelte';
	import { fade, fly } from 'svelte/transition';

	let { commentData, color = '#64B42D', direction = 'left', delay = { in: 0, out: 0 } } = $props();
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
		<Bubble {color} {direction}>
			{comment.text}
		</Bubble>
	</div>
{/each}

<style lang="scss">
	.comment-item {
		position: absolute;
		font-family: serif;
		font-size: clamp(0.9rem, 3rem, 2rem);
		color: $color-beacon-light-green;
		line-height: 1.3;
		padding: 0.5rem;

		&.fade-in {
			opacity: 1;
			transform: scale(1) translateY(0);
		}
	}
</style>
