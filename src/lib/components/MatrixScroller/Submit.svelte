<script>
	import { userResponse } from '$lib/stores/userResponse.js';
	import smoothScroll from '$lib/helpers/smoothScroll.js';
	import { fade } from 'svelte/transition';

	function submit() {
		$userResponse.submitted = true;

		setTimeout(() => {
			smoothScroll(".matrix.slide[data-index='1']");
		}, 10);
	}
</script>

{#if !$userResponse.submitted}
	<span class="instructions drag" transition:fade
		>Drag the dot to your guess.<button onclick={submit}>Submit</button></span
	>
{/if}

<style lang="scss">
	@import '$lib/styles/mixins.scss';

	button {
		padding: 0.5rem 1rem;
		margin-left: 1rem;
		border: none;
		cursor: pointer;
		border-radius: 12px;
		font-size: 1rem;
		font-weight: 600;
        transition: all 0.3s ease;
		background: var(--color-theme-blue-light);
		color: var(--color-theme-blue);
		box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);

		&:hover {
			// background: #ffffff;
			box-shadow: 0 8px 24px rgba(0, 0, 0, 0.25);
		}
	}
</style>
