<script>
	import { onMount } from 'svelte';
	import { gsap } from 'gsap';
	import { ScrollTrigger } from 'gsap/ScrollTrigger';

	// ===== CONFIG =====
	// Paste your Apps Script Web App URL (ends with /exec)
	const WEB_APP_URL =
		'https://script.google.com/macros/s/AKfycbxiJGG8bz08MzcPVAFqrC_9KANbfSYIi5ajUBDGHLU52v7AF9lpSIdiKG0jWKV2cNhp/exec';


	// ===== Refs =====
	let sectionElement;
	let contentElement;
	let emailInput;
	let submitButton;
	let honeypotInput; // hidden anti-bot field

	// ===== State (Svelte 5 runes) =====
	let progress = $state(0);
	let submitting = $state(false);
	let showSuccess = $state(false);

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

	function showSuccessMessage() {
		showSuccess = true;
		setTimeout(() => {
			showSuccess = false;
		}, 2000);
	}

	function validEmail(str) {
		// lightweight check; Apps Script should still validate/clean on server
		return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(str);
	}

	async function handleSubmit(event) {
		event.preventDefault();

		const email = (emailInput?.value || '').trim();
		const hp = (honeypotInput?.value || '').trim(); // should be empty

		if (hp) {
			// Bot likely filled the hidden field—silently succeed
			showSuccessMessage();
			event.target.reset();
			return;
		}

		if (!email) {
			return;
		}

		if (!validEmail(email)) {
			return;
		}

		try {
			submitting = true;

			const res = await fetch(WEB_APP_URL, {
				method: 'POST',
				headers: { 'Content-Type': 'text/plain' },
				body: email
			});

			// Apps Script typically always returns 200; check payload
			const json = await res.json().catch(() => ({}));

			if (json?.ok) {
				showSuccessMessage();
				event.target.reset();
			}
		} catch (err) {
			// Silently handle errors for better UX
		} finally {
			submitting = false;
		}
	}
</script>

<section id="email-signup" class="email-signup-section" bind:this={sectionElement}>
	<div class="email-signup-container" bind:this={contentElement}>
		<h2>Learn more about our effort to rethink responsibility in America.</h2>
		<p>
			We are on a mission to build a country that recognizes each American’s right and
			responsibility to improve their own lives and the lives of others. Enter your email below to
			subscribe to our newsletter and receive monthly updates on our work.
		</p>

		<form onsubmit={handleSubmit} class="signup-form">
			<!-- Honeypot (hidden) -->
			<input
				type="text"
				name="website"
				autocomplete="off"
				tabindex="-1"
				bind:this={honeypotInput}
				class="hp"
				aria-hidden="true"
			/>

			<input
				type="email"
				placeholder="Enter your email address"
				bind:this={emailInput}
				required
				class="email-input"
				autocomplete="email"
				inputmode="email"
				aria-label="Email address"
			/>

			{#if showSuccess}
				<div class="toast" role="alert" aria-live="polite">
					Success! You're subscribed.
				</div>
			{/if}

			<button
				type="submit"
				bind:this={submitButton}
				class="submit-button"
				disabled={submitting}
				aria-busy={submitting}
			>
				{submitting ? 'Submitting…' : 'Subscribe'}
			</button>
		</form>
	</div>
</section>

<style lang="scss">
	@import '../styles/variables.scss';
	@import '../styles/mixins.scss';

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
			background: radial-gradient(circle at 30% 20%, rgba(255, 255, 255, 0.1) 0%, transparent 50%);
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

			p {
				font-size: 1.2rem;
				line-height: 1.6;
				margin: 0 0 3rem 0;

				color: var(--color-theme-light);
			}

				.signup-form {
					display: flex;
					gap: 1rem;
					width: 100%;
					border-radius: 16px;
					padding: 1.5rem;
					box-shadow: 0 12px 40px rgba(0, 0, 0, 0.2);
					transition: all 0.3s ease;
					@include glass-effect(rgba(255, 255, 255, 0.15), rgba(255, 255, 255, 0.25), 15px);
					align-items: center;
					position: relative;

				&:hover {
					box-shadow: 0 16px 48px rgba(0, 0, 0, 0.25);
				}

				// Honeypot visually hidden but still in DOM
				.hp {
					position: absolute !important;
					left: -9999px !important;
					width: 1px;
					height: 1px;
					opacity: 0;
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

				.toast {
					position: absolute;
					bottom: 100%;
					left: 50%;
					transform: translateX(-50%);
					background: rgba(255, 255, 255, 0.95);
					color: var(--color-theme-blue);
					padding: 0.75rem 1.5rem;
					border-radius: 8px;
					font-size: 0.9rem;
					font-weight: 600;
					box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
					margin-bottom: 0.5rem;
					white-space: nowrap;
					animation: toastSlideIn 0.3s ease-out;
					z-index: 10;

					@keyframes toastSlideIn {
						from {
							opacity: 0;
							transform: translateX(-50%) translateY(10px);
						}
						to {
							opacity: 1;
							transform: translateX(-50%) translateY(0);
						}
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
					position: relative;

					&:hover {
						background: #ffffff;
						transform: translateY(-2px);
						box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
					}

					&:disabled {
						opacity: 0.7;
						cursor: default;
						transform: none;
						box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2);
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
						width: 100%;
					}

					.submit-button {
						width: 100%;
					}
				}
			}
		}
	}
</style>
