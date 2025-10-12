<script>
	import { fade } from 'svelte/transition';

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
