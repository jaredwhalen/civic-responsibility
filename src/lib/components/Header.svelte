<script>
	import { base } from '$app/paths';
	import { page } from '$app/stores';
	import { browser } from '$app/environment';
	import { beforeNavigate } from '$app/navigation';
	import { Home } from '@lucide/svelte';
	import Lockup from './Lockup.svelte';

	let { headerHeight = $bindable() } = $props();

	let bg = $derived($page.url.pathname.includes('/dashboard') || $page.url.pathname.includes('/quiz'));
	let previousPath = $state('');
	let isRoutePage = $derived($page.url.pathname.includes('/dashboard') || $page.url.pathname.includes('/quiz'));
	
	// Track the previous path to determine navigation behavior
	beforeNavigate((navigation) => {
		if (navigation.from) {
			previousPath = navigation.from.url.pathname;
		}
	});

	// Determine if we came directly from root
	let cameDirectlyFromRoot = $derived.by(() => {
		if (!isRoutePage) return false;
		// Check if previous path was root (/ or /base)
		return previousPath === '/' || previousPath === base || previousPath === base + '/';
	});

	// Derive button text based on navigation state
	let backButtonText = $derived(cameDirectlyFromRoot ? 'Go back home' : 'Home');

	function handleBackClick() {
		if (cameDirectlyFromRoot && browser) {
			// Use browser back to maintain scroll position when coming directly from root
			window.history.back();
		} else {
			// Navigate to root page for all other cases (came from another route, external, etc)
			window.location.href = base + '/';
		}
	}
</script>

<header class="main-header" aria-label="Site navigation" bind:clientHeight={headerHeight} class:bg>
	<div class="header-left">
		<Lockup size="large" />
	</div>

	<div class="header-right">
		{#if isRoutePage}
			<button class="nav-button back-button" onclick={handleBackClick}>
				<Home size={16} />
				{backButtonText}
			</button>
		{/if}
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

				&.back-button {
					color: var(--color-theme-light);
					background: rgba(255, 255, 255, 0.1);
					border: 1px solid rgba(255, 255, 255, 0.2);
					display: flex;
					align-items: center;
					gap: 0.5rem;
					
					&:hover {
						background: rgba(255, 255, 255, 0.15);
						border-color: rgba(255, 255, 255, 0.3);
					}
				}
			}
		}
	}
</style>
