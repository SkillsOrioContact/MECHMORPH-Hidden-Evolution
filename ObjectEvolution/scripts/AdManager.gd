extends Node

# Placeholders for AdMob Ad Unit IDs
const REWARDED_AD_UNIT_ID = "ca-app-pub-3940256099942544/5224354917" # Google Test ID
const INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-3940256099942544/1033173712" # Google Test ID

signal reward_earned(reward_type, amount)
signal interstitial_closed

var ad_ready_rewarded: bool = true
var ad_ready_interstitial: bool = true

func _ready():
    print("AdManager initialized with test IDs.")
    # Initialize Godot AdMob plugin here when installed on local machine
    # MobileAds.initialize()

func show_rewarded_ad(reward_type: String):
    if not ad_ready_rewarded:
        print("Rewarded ad not ready.")
        return

    print("Showing Rewarded Ad for: ", reward_type)
    # Simulate ad playback
    await get_tree().create_timer(1.0).timeout
    emit_signal("reward_earned", reward_type, 1)

    # Handle the rewards
    if reward_type == "revive":
        print("Player revived via Ad!")
    elif reward_type == "double_rewards":
        print("Rewards doubled via Ad!")

func show_interstitial_ad():
    if not ad_ready_interstitial:
        print("Interstitial ad not ready.")
        return

    print("Showing Interstitial Ad")
    # Simulate ad playback
    await get_tree().create_timer(1.0).timeout
    emit_signal("interstitial_closed")
    print("Interstitial Ad Closed. Resuming game flow.")
