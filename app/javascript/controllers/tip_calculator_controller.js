import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tip-calculator"
// Handles real-time tip calculations without server round-trips
export default class extends Controller {
  static targets = [
    "billAmount",
    "tipPercentage",
    "customTip",
    "peopleCount",
    "tipAmount",
    "totalAmount",
    "perPersonAmount",
    "result",
    "toastContainer"
  ]

  static values = {
    selectedTip: { type: Number, default: 15 }
  }

  connect() {
    // Initialize with default values
    this.calculate()
  }

  // Select a preset tip percentage
  selectTip(event) {
    event.preventDefault()
    const percentage = parseFloat(event.currentTarget.dataset.tip)
    
    // Update selected tip value
    this.selectedTipValue = percentage
    
    // Clear custom tip input
    if (this.hasCustomTipTarget) {
      this.customTipTarget.value = ""
    }
    
    // Update tip percentage hidden field
    if (this.hasTipPercentageTarget) {
      this.tipPercentageTarget.value = percentage
    }
    
    // Update button states
    this.updateTipButtons(percentage)
    
    // Recalculate
    this.calculate()
  }

  // Handle custom tip input
  customTipInput(event) {
    const value = parseFloat(event.target.value)
    
    if (!isNaN(value) && value >= 0 && value <= 100) {
      this.selectedTipValue = value
      
      // Update tip percentage hidden field
      if (this.hasTipPercentageTarget) {
        this.tipPercentageTarget.value = value
      }
      
      // Deselect all preset buttons
      this.updateTipButtons(null)
      
      // Recalculate
      this.calculate()
    }
  }

  // Update people count
  updatePeople(event) {
    const value = parseInt(event.target.value)
    if (value > 0) {
      this.calculate()
    }
  }

  // Increment people count
  incrementPeople(event) {
    event.preventDefault()
    const current = parseInt(this.peopleCountTarget.value) || 1
    this.peopleCountTarget.value = current + 1
    this.calculate()
  }

  // Decrement people count (minimum 1)
  decrementPeople(event) {
    event.preventDefault()
    const current = parseInt(this.peopleCountTarget.value) || 1
    if (current > 1) {
      this.peopleCountTarget.value = current - 1
      this.calculate()
    }
  }

  // Main calculation method
  calculate() {
    const billAmount = parseFloat(this.billAmountTarget.value) || 0
    const tipPercentage = this.selectedTipValue || 0
    const peopleCount = parseInt(this.peopleCountTarget.value) || 1

    // Validate inputs
    if (billAmount <= 0) {
      this.clearResults()
      return
    }

    // Perform calculations
    const totalTip = (billAmount * tipPercentage / 100)
    const totalAmount = billAmount + totalTip
    const tipAmountPerPerson = totalTip / peopleCount
    const totalPerPerson = totalAmount / peopleCount

    // Update display
    this.tipAmountTarget.textContent = this.formatCurrency(tipAmountPerPerson)
    this.totalAmountTarget.textContent = this.formatCurrency(totalAmount)
    this.perPersonAmountTarget.textContent = this.formatCurrency(totalPerPerson)

    // Show results
    if (this.hasResultTarget) {
      this.resultTarget.classList.remove("hidden")
    }
  }

  // Reset the calculator
  reset(event) {
    event.preventDefault()
    
    // Clear inputs
    this.billAmountTarget.value = ""
    if (this.hasCustomTipTarget) {
      this.customTipTarget.value = ""
    }
    this.peopleCountTarget.value = 1
    
    // Reset tip to default (15%)
    this.selectedTipValue = 15
    if (this.hasTipPercentageTarget) {
      this.tipPercentageTarget.value = 15
    }
    this.updateTipButtons(15)
    
    // Clear results
    this.clearResults()
  }

  // Clear result display
  clearResults() {
    this.tipAmountTarget.textContent = "UGX 0"
    this.totalAmountTarget.textContent = "UGX 0"
    this.perPersonAmountTarget.textContent = "UGX 0"
  }

  // Format number as currency (Ugandan Shillings)
  formatCurrency(amount) {
    return new Intl.NumberFormat('en-UG', {
      style: 'currency',
      currency: 'UGX',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(amount)
  }

  // Update tip button active states
  updateTipButtons(activePercentage) {
    const buttons = this.element.querySelectorAll('[data-tip]')
    buttons.forEach(button => {
      const buttonTip = parseFloat(button.dataset.tip)
      if (buttonTip === activePercentage) {
        button.classList.add('active')
      } else {
        button.classList.remove('active')
      }
    })
  }

  // Handle Turbo form submission completion
  handleSubmitEnd(event) {
    if (event.detail.success) {
      // Show success toast
      this.showToast('✓ Calculation saved successfully!', 'success')
      
      // Reset the form after a brief delay
      setTimeout(() => {
        this.resetForm()
      }, 100)
    } else {
      // Show error toast
      this.showToast('✗ Failed to save calculation', 'error')
    }
  }

  // Reset form without preventing default (called after successful submit)
  resetForm() {
    // Clear inputs
    this.billAmountTarget.value = ""
    if (this.hasCustomTipTarget) {
      this.customTipTarget.value = ""
    }
    this.peopleCountTarget.value = 1
    
    // Reset tip to default (15%)
    this.selectedTipValue = 15
    if (this.hasTipPercentageTarget) {
      this.tipPercentageTarget.value = 15
    }
    this.updateTipButtons(15)
    
    // Clear results
    this.clearResults()
    
    // Focus back on bill amount for next calculation
    this.billAmountTarget.focus()
  }

  // Show toast notification
  showToast(message, type = 'success') {
    // Find or create toast container
    let container = document.getElementById('toast-container')
    if (!container) {
      container = document.createElement('div')
      container.id = 'toast-container'
      container.className = 'toast-container'
      document.body.appendChild(container)
    }

    // Create toast element
    const toast = document.createElement('div')
    toast.className = `toast toast-${type}`
    toast.innerHTML = `
      <span class="toast-message">${message}</span>
    `

    // Add to container
    container.appendChild(toast)

    // Trigger animation
    setTimeout(() => toast.classList.add('toast-visible'), 10)

    // Auto-remove after 3 seconds
    setTimeout(() => {
      toast.classList.remove('toast-visible')
      toast.classList.add('toast-hiding')
      setTimeout(() => toast.remove(), 300)
    }, 3000)
  }
}
