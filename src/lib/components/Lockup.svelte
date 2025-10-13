<script>
	import { base } from '$app/paths';
	
	let { 
		size = 'large', // 'large', 'medium', 'small'
		showSeparator = true,
		className = ''
	} = $props();
</script>

<div class="lockup {className} size-{size}">
	<a href="https://moreincommonus.com/" target="_blank" rel="noopener noreferrer">
		<img class="logo mic-logo" src={base + '/assets/icons/moreincommon.png'} alt="More in Common logo" />
	</a>
	{#if showSeparator}
		<div class="logo-separator"></div>
	{/if}
	<a href="https://beaconproject.us/" target="_blank" rel="noopener noreferrer">
		<img class="logo beacon-logo" src={base + '/assets/icons/beaconproject.png'} alt="Beacon Project logo" />
	</a>
</div>

<style lang="scss">
	@import '../styles/mixins.scss';

	.lockup {
		display: flex;
		align-items: center;
		gap: $spacing-md;
		pointer-events: auto;

		a {
			display: block;
			line-height: 0;
		}

		.logo {
			width: auto;
			transition: opacity 0.3s ease;

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

			@include mq('mobile', 'max') {
				.logo {
					height: 30px;
				}

				.logo-separator {
					height: 30px;
				}
			}

			@include mq('small-mobile', 'max') {
				.logo {
					height: 25px;
				}

				.logo-separator {
					height: 25px;
				}
			}
		}

		&.size-medium {
			.logo {
				height: 40px;
			}

			.logo-separator {
				height: 30px;
			}

			@include mq('mobile', 'max') {
				.logo {
					height: 25px;
				}

				.logo-separator {
					height: 20px;
				}
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
