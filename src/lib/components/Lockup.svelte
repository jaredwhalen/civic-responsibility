<script>
	import { base } from '$app/paths';

	let {
		size = 'large', // 'large', 'medium', 'small'
		showSeparator = true,
		className = '',
		interactive = true
	} = $props();
</script>

<div class="lockup {className} size-{size}" class:interactive>
	<a href="https://moreincommonus.com/" target="_blank" rel="noopener noreferrer">
		<img
			class="logo mic-logo"
			src={base + '/assets/icons/moreincommon.png'}
			alt="More in Common logo"
		/>
	</a>
	{#if showSeparator}
		<div class="logo-separator"></div>
	{/if}
	<a href="https://beaconproject.us/" target="_blank" rel="noopener noreferrer">
		<img
			class="logo beacon-logo"
			src={base + '/assets/icons/beaconproject.png'}
			alt="Beacon Project logo"
		/>
	</a>
</div>

<style lang="scss">
	@import '../styles/mixins.scss';

	.lockup {
		display: flex;
		align-items: center;
		gap: $spacing-md;
		pointer-events: none;
		flex-shrink: 0; // Prevent lockup from squishing
		&.interactive {
			pointer-events: auto;
		}
		@include mq('mobile', 'max') {
			gap: 0px;
		}

		a {
			display: block;
			line-height: 0;
			flex-shrink: 0; // Prevent logos from squishing
		}

		.logo {
			width: auto;
			transition: opacity 0.3s ease;
			flex-shrink: 0; // Prevent logos from squishing

			&:hover {
				opacity: 0.8;
			}
		}

		.logo-separator {
			width: 2px;
			background-color: #fff;
		}

		// Size variants
		&.size-large {
			.logo {
				height: 80px;
			}

			.logo-separator {
				height: 60px;
			}
		}

		&.size-medium {
			.logo {
				height: 45px;
			}

			.logo-separator {
				height: 35px;
				width: 1px;
			}
		}

		&.size-small {
			.logo {
				height: 24px;
			}

			.logo-separator {
				height: 18px;
			}
		}
	}
</style>
