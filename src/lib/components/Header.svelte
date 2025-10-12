<script>
	import { base } from '$app/paths';
	import { page } from '$app/stores';

	let { headerHeight = $bindable() } = $props();

	let bg = $derived($page.url.pathname.includes('/dashboard') || $page.url.pathname.includes('/quiz'));
</script>

<header class="main-header" aria-label="Site navigation" bind:clientHeight={headerHeight} class:bg>
	<div class="header-left">
		<a href="https://moreincommonus.com/" target="_blank" rel="noopener noreferrer">
			<img class="logo" src={base + '/assets/icons/moreincommon.png'} alt="More in Common logo" />
		</a>
		<div class="logo-separator"></div>
		<a href="https://beaconproject.us/" target="_blank" rel="noopener noreferrer">
			<img class="logo" src={base + '/assets/icons/beaconproject.png'} alt="Beacon Project logo" />
		</a>
	</div>

	<div class="header-right">
		{#if !$page.url.pathname.includes('/dashboard')}
			<a href={base + '/dashboard'} class="nav-button dashboard-button"> View the data dashboard </a>
		{/if}
		{#if !$page.url.pathname.includes('/quiz')}
			<a href={base + '/quiz'} class="nav-button quiz-button">
				What's your Civic Profile? Take our interactive quiz.
			</a>
		{/if}
	</div>
</header>

<style lang="scss">
	.main-header {
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: $spacing-sm $spacing-lg;
		z-index: 2000;
		pointer-events: none;
		height: 80px;
		&.bg {
			background: var(--color-theme-blue);
		}

		// Mobile responsive adjustments
		@include mq('mobile', 'max') {
			height: 60px;
			padding: $spacing-xs $spacing-md;
		}

		@include mq('small-mobile', 'max') {
			height: 50px;
			padding: $spacing-xs $spacing-sm;
		}

		.header-left {
			pointer-events: auto;
			display: flex;
			align-items: center;
			gap: $spacing-md;

			a {
				display: block;
				line-height: 0;
			}

			.logo {
				height: 80px;
				width: auto;

				// Mobile responsive logo sizing
				@include mq('mobile', 'max') {
					height: 30px;
				}

				@include mq('small-mobile', 'max') {
					height: 25px;
				}
			}

			.logo-separator {
				width: 2px;
				height: 60px;
				background-color: #fff;

				// Mobile responsive separator sizing
				@include mq('mobile', 'max') {
					height: 30px;
				}

				@include mq('small-mobile', 'max') {
					height: 25px;
				}
			}
		}

		.header-right {
			pointer-events: auto;
			display: flex;
			gap: $spacing-md;
			align-items: center;

			// Hide buttons on smaller screens
			@include mq('mobile', 'max') {
				gap: $spacing-sm;
			}

			@include mq('small-mobile', 'max') {
				display: none;
			}

			.nav-button {
				padding: 0.5rem 1rem;
				border-radius: 6px;
				cursor: pointer;
				font-size: 0.9rem;
				font-weight: 600;
				text-decoration: none;
				transition: all 0.3s ease;
				white-space: nowrap;
				display: inline-block;
				@include glass-effect(rgba(255, 255, 255, 0.15), rgba(255, 255, 255, 0.3));

				@include mq('mobile', 'max') {
					padding: 0.4rem 0.8rem;
					font-size: 0.8rem;
				}

				&:hover {
					transform: translateY(-2px);
					box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
				}

				&.dashboard-button {
					color: var(--color-theme-light);
				}

				&.quiz-button {
					color: var(--color-theme-light);
				}
			}
		}
	}
</style>
