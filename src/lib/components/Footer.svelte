<script>
	import Lockup from './Lockup.svelte';
</script>

<footer class="footer-root">
	<div class="footer-beacon-section">
		<div class="beacon-text">
			This website was produced by the
			<a class="beacon-project" href="https://beaconproject.us/" target="_blank">Beacon Project</a>
		</div>
		<a class="learn-more-button" href="https://beaconproject.us/" target="_blank">Learn More</a>
	</div>

	<div class="footer-content">
		<div class="footer-about-columns">
			<div class="footer-section">
				<h2 class="footer-title">About The Beacon Project</h2>
				<p>
					We are a multi-year effort at More in Common to develop a new civic vision that can speak to America’s Exhausted Majority.
				</p>
			</div>
			<div class="footer-section">
				<h2 class="footer-title">About More In Common</h2>
				<p>
					Our mission is to understand the forces driving societies apart, find common ground, and
					bring people together to tackle shared challenges. We work in partnership with a wide
					range of civil society groups, as well as philanthropy, business, faith, education, media
					and government to connect people across the lines of difference.
				</p>
			</div>
		</div>
	</div>

	<div class="footer-logos">
		<Lockup size="large" />
	</div>

	<div class="footer-contact">
		<p>
			For questions or technical issues, please contact us at
			<a href="mailto:beaconproject@moreincommon.com">beaconproject@moreincommon.com</a>
		</p>
	</div>
</footer>

<style lang="scss">
	@import '../styles/mixins.scss';

	.footer-root {
		background: linear-gradient(135deg, var(--color-theme-blue), #111);
		color: #fff;
		padding: 1rem 3rem 1rem;
		position: relative;
		box-shadow: 0 2px 12px rgba(0, 0, 0, 0.12);
		font-family: $font-family-primary;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: 1rem;
		z-index: 1000;

		@include mq('mobile', 'max') {
			padding: 1rem;
		}
	}

	.footer-beacon-section {
		display: flex;
		flex-direction: column;
		align-items: center;
		text-align: center;
		gap: 1rem;
		max-width: 800px;
		margin: 3rem auto;

		@include mq('mobile', 'max') {
			margin: 1rem auto;
			padding: 0px;
		}
	}

	.footer-content {
		display: flex;
		flex-direction: column;
		gap: 2rem;
		max-width: 1200px;
		margin: 0 auto;
		width: 100%;
	}

	.footer-about-columns {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 3rem;
	}

	.footer-section {
		margin-bottom: 0.5rem;
	}

	.footer-title {
		color: #f9d246;
		font-size: 1.1rem;
		font-weight: 600;
		margin-bottom: 0.5rem;
		letter-spacing: 0.03em;
	}

	.beacon-text {
		font-size: 1.4rem;
		font-weight: 300;
		line-height: 1.2;
		color: #fff;



		.beacon-project {
			font-family: 'Aboreto', serif;
			font-weight: 400;
			font-size: 3rem;
			display: block;
			margin-top: 0.5rem;
			color: #e3c14c;
			text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
		}
	}

	.learn-more-button {
		@include glass-effect(rgba(255, 255, 255, 0.1), rgba(255, 255, 255, 0.2));
		padding: 0.5rem 1rem;
		border-radius: 12px;
		border: none;
		cursor: pointer;
		font-size: 1.1rem;
		font-weight: 600;
		color: #fff;
		transition: all 0.3s ease;
		min-width: 180px;

		&:hover {
			background: rgba(255, 255, 255, 0.15);
			border-color: rgba(255, 255, 255, 0.3);
			transform: translateY(-2px);
			box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
		}
	}

	.footer-logos {
		align-self: flex-end;
	}

	.footer-contact {
		text-align: center;
		font-size: 0.9rem;
		opacity: 0.8;
		margin-top: 0.5rem;
		padding-top: 1rem;
		border-top: 1px solid rgba(255, 255, 255, 0.1);
		width: 100%;

		p {
			margin: 0;
		}

		a {
			color: #f9d246;
			text-decoration: none;
			font-weight: 500;
			transition: opacity 0.2s ease;

			&:hover {
				opacity: 0.8;
				text-decoration: underline;
			}
		}
	}

	@include mq('mobile', 'max') {
		.footer-beacon-section {
			max-width: 100%;
			padding: 0 1rem;
			margin-bottom: 2rem;
		}

		.beacon-text {
			font-size: .4rem;
		}

		.learn-more-button {
			padding: 0.875rem 2rem;
			font-size: 1rem;
			min-width: 160px;
		}

		.footer-content {
			max-width: 100%;
		}

		.footer-about-columns {
			grid-template-columns: 1fr;
			gap: 2rem;
		}

		.footer-logos {
			align-self: center;
		}

		.footer-contact {
			font-size: 0.85rem;
			padding: 1.5rem 1rem 0;
		}
	}
</style>
