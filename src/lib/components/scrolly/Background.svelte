<script>
	import { fade } from 'svelte/transition';
	import _1_blobs from './states/_1-blobs.svelte';
	import _1_people from './states/_1-people.svelte';
	import _2_liberty_bell from './states/_2-liberty-bell.svelte';
	import _2_images from './states/_2-images.svelte';
	import _3_definition from './states/_3-definition.svelte';
	import _4_answers_expected from './states/_4-answers-expected.svelte';
	import _5_answers_surprising from './states/_5-answers-surprising.svelte';

	import Dashboard from '../dashboard/Dashboard.svelte';

	let {
		count,
		index,
		offset,
		progress,
		activeId,
		showDashboard = false,
		interactiveMode = $bindable()
	} = $props();

	// Map activeId to component
	const components = {
		'1-blobs': _1_blobs,
		'2-liberty-bell': _2_liberty_bell,
		'2-images': _2_images,
		'3-definition': _3_definition,
		'4-answers-expected': _4_answers_expected,
		'5-answers-surprising': _5_answers_surprising
		// Add more mappings as needed
	};

	// Get the correct component for the current activeId
	let ActiveComponent = $derived(components[activeId]);
	
	// Generate accessible background description
	const backgroundDescription = $derived(`Background visual for ${activeId || 'current slide'}`);
</script>

{#if showDashboard}
	<div
		class="dashboard-wrapper {interactiveMode ? 'interactive-mode' : ''}"
		class:visible={showDashboard}
		in:fade={{ duration: 500, delay: 500 }}
		out:fade={{ duration: 500 }}
		role="region"
		aria-label="Interactive dashboard"
		aria-describedby="dashboard-content"
	>

		<Dashboard {activeId} bind:interactiveMode />
	</div>
{/if}

{#key activeId}
	<div 
		class="scrolly-bg"
		role="presentation"
		aria-label={backgroundDescription}
		aria-hidden="true"
	>
		<div class="scrolly-bg-inner">
			{#if ActiveComponent}
				<ActiveComponent {offset} />
			{/if}
		</div>
	</div>
{/key}

<style lang="scss">
	@import '$lib/styles/mixins.scss';
	
	.scrolly-bg {
		position: sticky;
		top: 0;
		right: 0;
		left: 40%;
		width: 60%;
		height: 100vh;
		z-index: -1;
		display: flex;
		align-items: center;
		justify-content: center;

		// Mobile responsive - full width
		@include mq('mobile', 'max') {
			left: 0;
			width: 100%;
			position: relative;
		}



		.scrolly-bg-inner {
			width: 100%;
			height: 100%;
		}
	}

	.dashboard-wrapper {
		opacity: 0;
		width: 100%;
		height: 100%;
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		pointer-events: none;

		&.visible {
			opacity: 1;
			pointer-events: auto;
		}
		

	}
	


</style>
