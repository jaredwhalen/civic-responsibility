<script>
	import Step_1 from './_steps/_1/Step_1.svelte';
	import Step_2 from './_steps/_2/Step_2.svelte';
	import Step_3 from './_steps/_3/Step_3.svelte';
	import Step_4 from './_steps/_4/Step_4.svelte';
	import Step_5 from './_steps/_5/Step_5.svelte';

	import Step_12 from './_steps/_12/Step_12.svelte';
	import Step_13 from './_steps/_13/Step_13.svelte';

	let { section } = $props();
</script>

<div class="scroller">
	{#if section == 'intro'}
		<div class="dark-bg">
			<Step_1 />
			<Step_2 />
		</div>
	
		<Step_3 />
		<div class="dark-bg reverse">
			<Step_4 />
			<Step_5 />
		</div>
	{/if}

	{#if section == 'outro'}
		<Step_12 />
		<Step_13 />
	{/if}
</div>

<style lang="scss">
	@import '../../styles/variables.scss';
	@import '../../styles/mixins.scss';

	.scroller {
		position: relative;
		width: 100%;
		z-index: 10;
		overflow-x: clip;
	}

	// Global text classes for consistent typography
	:global(.text-hero) {
		font-size: 3rem;
		font-weight: 700;
		color: inherit;
		margin: 0;
		line-height: 1.2;
		letter-spacing: 0.02em;

		// Mobile responsive sizing
		@include mq('tablet', 'max') {
			font-size: 2.5rem;
		}

		@include mq('mobile', 'max') {
			font-size: 2rem;
			line-height: 1.3;
		}

		@include mq('small-mobile', 'max') {
			font-size: 1.75rem;
		}
	}

	:global(.text-body) {
		font-size: 2.8rem;
		font-weight: 400;
		color: inherit;
		line-height: 1.2;
		letter-spacing: 0.02em;

		// Mobile responsive sizing
		@include mq('tablet', 'max') {
			font-size: 2.3rem;
		}

		@include mq('mobile', 'max') {
			font-size: 1.8rem;
			line-height: 1.3;
		}

		@include mq('small-mobile', 'max') {
			font-size: 1.5rem;
		}
	}

	:global(.text-accent) {
		font-weight: 700;
		font-size: 2.8rem;
		position: relative;
		display: inline-block;

		// Mobile responsive sizing
		@include mq('tablet', 'max') {
			font-size: 2.3rem;
		}

		@include mq('mobile', 'max') {
			font-size: 1.8rem;
		}

		@include mq('small-mobile', 'max') {
			font-size: 1.5rem;
		}
	}

	.light-bg {
		background: linear-gradient(135deg, var(--bg-color), #fff);
	}

	.dark-bg {
		background: linear-gradient(135deg, var(--color-theme-blue), #111);

		&.reverse {
			background: linear-gradient(135deg, #111, var(--color-theme-blue));
		}
	}
</style>
