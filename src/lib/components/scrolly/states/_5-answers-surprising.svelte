<script>
	import { onMount } from 'svelte';
	import Comments from '../Comments.svelte';
	import { fade, fly } from 'svelte/transition';

	let { activeId } = $props();

	const STATE_ID = '5-answers-surprising';

	// Combined array with answers and their positions
	const commentData = [
		{
			text: 'Tolerating differences',
			position: { top: '15%', left: '10%'}
		},
		{
			text: 'Protecting the environment',
			position: { top: '10%', left: '55%'}
		},
		{
			text: 'Being grateful for your opportunities',
			position: { top: '65%', left: '50%'}
		},
		{
			text: 'Caring for future generation',
			position: { top: '50%', left: '15%'}
		},
		{
			text: 'Making one’s voice heard',
			position: { top: '80%', left: '10%'}
		},
		{
			text: 'Helping one’s community',
			position: { top: '35%', left: '50%'}
		}
	];
</script>

<div class="answers-container">
	<Comments {commentData} color="#FAD246" direction="right" delay={{ in: 500, out: 0 }} />
</div>

<style lang="scss">
	.answers-container {
		width: 100%;
		height: 100%;
		font-family: $font-family-body;
		position: absolute;
		top: 0;
		left: 0;
		z-index: 1;
	}
</style>
