<script>
	import { onMount } from 'svelte';
	import Comments from '../Comments.svelte';
	import { fade, fly } from 'svelte/transition';
	import { getCSSVar } from '$lib/helpers/getCSSVar';

	let { activeId } = $props();

	const STATE_ID = '4-answers-expected';

	// Combined array with answers and their positions
	const commentData = [
		{
			text: 'Obeying the law',
			position: { top: '15%', left: '0%', color: `${getCSSVar('--color-theme-red')}50`}
		},
		{
			text: 'Honoring the Constitution',
			position: { top: '20%', left: '55%', color: `${getCSSVar('--color-theme-blue')}50`}
		},
		{
			text: 'Paying your taxes',
			position: { top: '70%', left: '15%', color: `${getCSSVar('--color-theme-red')}50`}
		},
		{
			text: 'Serving on a jury',
			position: { top: '55%', left: '50%', color: `${getCSSVar('--color-theme-blue')}50`}
		},
		{
			text: 'Voting',
			position: { top: '80%', left: '70%', color: `${getCSSVar('--color-theme-red')}50`}
		},
		{
			text: 'Practicing freedom of speech',
			position: { top: '35%', left: '10%', color: `${getCSSVar('--color-theme-blue')}50`}
		}
	];


</script>

<div class="answers-container">
	<Comments {commentData} delay={{ in: 500, out: 0 }}/>
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
