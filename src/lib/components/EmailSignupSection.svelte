<script>
	import { onMount } from 'svelte';
	import { gsap } from 'gsap';
	import { ScrollTrigger } from 'gsap/ScrollTrigger';

	let sectionElement;
	let contentElement;
	let emailInput;
	let submitButton;
	let progress = $state(0);

	// Reactive calculations based on scroll progress
	let contentScale = $derived(progress >= 10 ? 1 : 0.8);
	let contentOpacity = $derived(progress >= 10 ? 1 : 0);

	onMount(() => {
		gsap.registerPlugin(ScrollTrigger);

		// Set initial states for content
		gsap.set(contentElement, { scale: 0.8, opacity: 0 });

		// Create scroll trigger for this section
		const trigger = ScrollTrigger.create({
			trigger: sectionElement,
			start: 'top 80%',
			end: 'bottom 20%',
			onUpdate: (self) => {
				progress = self.progress * 100;
			}
		});

		return () => {
			trigger.kill();
		};
	});

	// Watch for progress changes and update animations
	$effect(() => {
		if (contentElement) {
			gsap.to(contentElement, {
				scale: contentScale,
				opacity: contentOpacity,
				duration: 0.1,
				ease: 'none'
			});
		}
	});

	function handleSubmit(event) {
		event.preventDefault();
		// TODO: Handle email submission
		console.log('Email submitted:', emailInput.value);
	}
</script>

<section class="email-signup-section" bind:this={sectionElement}>
	<div class="email-signup-container" bind:this={contentElement}>
		<h2>Learn more about our effort to rethink responsibility in America.</h2>
		
		<form onsubmit={handleSubmit} class="signup-form">
			<input 
				type="email" 
				placeholder="Enter your email address" 
				bind:this={emailInput}
				required
				class="email-input"
			/>
			<button type="submit" bind:this={submitButton} class="submit-button">
				Subscribe
			</button>
		</form>
	</div>
</section>

<style lang="scss">
	@import '../styles/variables.scss';

	.email-signup-section {
        z-index: 1;
		width: 100%;
		padding: 8rem 2rem;
		background: linear-gradient(
			135deg,
			var(--color-theme-blue) 0%,
			var(--color-theme-blue-light) 100%
		);
		position: relative;
		overflow: hidden;
		will-change: transform, opacity;

		&::before {
			content: '';
			position: absolute;
			top: 0;
			left: 0;
			right: 0;
			bottom: 0;
			background: radial-gradient(
				circle at 30% 20%,
				rgba(255, 255, 255, 0.1) 0%,
				transparent 50%
			);
			pointer-events: none;
		}

		.email-signup-container {
			max-width: 800px;
			margin: 0 auto;
			text-align: center;
			position: relative;
			z-index: 1;
			will-change: transform, opacity;

			h2 {
				font-size: 2.5rem;
				font-weight: 600;
				margin: 0 0 3rem 0;
				line-height: 1.3;
				color: var(--color-theme-light);
				text-shadow: 0 2px 12px rgba(0, 0, 0, 0.2);
			}

			.signup-form {
				display: flex;
				gap: 1rem;
				width: 100%;
				background: rgba(255, 255, 255, 0.15);
				backdrop-filter: blur(15px);
				border: 1px solid rgba(255, 255, 255, 0.25);
				border-radius: 16px;
				padding: 1.5rem;
				box-shadow: 0 12px 40px rgba(0, 0, 0, 0.2);
				transition: all 0.3s ease;

				&:hover {
					background: rgba(255, 255, 255, 0.2);
					border-color: rgba(255, 255, 255, 0.35);
					box-shadow: 0 16px 48px rgba(0, 0, 0, 0.25);
				}

				.email-input {
					flex: 1;
					padding: 1rem 1.5rem;
					border: none;
					border-radius: 12px;
					background: rgba(255, 255, 255, 0.9);
					color: var(--color-theme-dark);
					font-size: 1rem;
					font-weight: 500;
					outline: none;
					transition: all 0.3s ease;

					&::placeholder {
						color: var(--color-theme-dark);
						opacity: 0.7;
					}

					&:focus {
						background: rgba(255, 255, 255, 1);
						box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.3);
					}
				}

				.submit-button {
					padding: 1rem 2rem;
					border: none;
					border-radius: 12px;
					background: var(--color-theme-light);
					color: var(--color-theme-blue);
					font-size: 1rem;
					font-weight: 600;
					cursor: pointer;
					transition: all 0.3s ease;
					white-space: nowrap;
					will-change: transform;
					box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2);

					&:hover {
						background: #ffffff;
						transform: translateY(-2px);
						box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
					}

					&:active {
						transform: translateY(0);
					}
				}
			}
		}
	}

	// Responsive design
	@media (max-width: 768px) {
		.email-signup-section {
			padding: 6rem 1.5rem;

			.email-signup-container {
				h2 {
					font-size: 2rem;
					margin-bottom: 2.5rem;
				}

				.signup-form {
					flex-direction: column;
					gap: 1rem;

					.email-input {
						text-align: center;
					}

					.submit-button {
						width: 100%;
					}
				}
			}
		}
	}
</style>
