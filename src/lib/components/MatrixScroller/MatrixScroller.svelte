<script>
	import Scroller from '$lib/components/MatrixScroller/_Scroller.svelte';
	import Background from '$lib/components/MatrixScroller/Background.svelte';
	import { userResponse } from '$lib/stores/userResponse.js';
	import Text from '$lib/components/MatrixScroller/Text.svelte';
	import { onMount } from 'svelte';

	let { content } = $props();

	let count = $state(0);
	let index = $state(0);
	let offset = $state(0);
	let progress = $state(0);
	let top = 0;
	let threshold = 0.5;
	let bottom = 1;

	let interactiveMode = $state(false);

	// Derived variables for each Scrolly component

	const activeSlide = $derived(content.scrolly.slidesFixed[$userResponse.submitted ? index : 0]);

	$inspect(index);

	$effect(() => {
		if (!$userResponse.submitted) {
			index = 0;
		}
	});
</script>

<Scroller
	{top}
	{threshold}
	{bottom}
	bind:count
	bind:index
	bind:offset
	bind:progress
	interactiveBg={Boolean(activeSlide.interactiveBg)}
	role="region"
	aria-label="Second interactive content scroll area"
>
	{#snippet background()}
		<div
			class="background-container"
			style="height: 100vh;"
			data-theme={activeSlide.theme || 'default'}
			role="presentation"
			aria-hidden="true"
		>
			<Background
				{count}
				{index}
				{offset}
				{progress}
				activeId={activeSlide.id}
				showDashboard={Boolean(activeSlide.showDashboard)}
				{interactiveMode}
			/>

			<div class="progress-indicator" class:hidden={!$userResponse.submitted} style:--slide-progress={offset}></div>
		</div>

		<Text content={activeSlide} />
	{/snippet}

	{#snippet foreground()}
		<div
			class="foreground-container {interactiveMode ? 'interactive-mode' : ''}"
			data-theme={activeSlide.theme || 'default'}
			role="main"
			aria-label="Second content slides"
		>
			{#each content.scrolly.slidesFixed as slide, slideIndex}
				<section
					class="matrix slide"
					data-index={slideIndex}
					class:first={slideIndex === 0}
					class:hidden={!$userResponse.submitted && slideIndex > 0}
				></section>
			{/each}
		</div>
	{/snippet}
</Scroller>

<style lang="scss">
	.slide {
		height: 70svh;
		position: relative;
		&.first {
			height: 100dvh;
		}

		&.hidden {
			display: none;
		}
	}

	.progress-indicator {
		position: absolute;
		bottom: 0;
		left: 0;
		width: 100%;
		height: 100%;

		&.hidden {
			display: none;
		}

		&::after {
			content: '';
			position: absolute;
			right: 2.5px;
			width: 10px;
			height: 10px;
			background: #000;
			border-radius: 50%;
			opacity: 0.3;
			bottom: calc(var(--slide-progress) * 100%);
		}
	}
</style>
