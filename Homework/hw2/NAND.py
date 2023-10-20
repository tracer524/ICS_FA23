import matplotlib.pyplot as plt
import matplotlib.patches as patches

# Create a new figure
fig, ax = plt.subplots()

# Draw NAND gate symbols
nand1 = patches.Rectangle((0, 3), 1, 1, linewidth=1, edgecolor='b', facecolor='none')
nand2 = patches.Rectangle((0, 1), 1, 1, linewidth=1, edgecolor='b', facecolor='none')
nand3 = patches.Rectangle((3, 2), 1, 1, linewidth=1, edgecolor='b', facecolor='none')
nand4 = patches.Rectangle((6, 2), 1, 1, linewidth=1, edgecolor='b', facecolor='none')
nand5 = patches.Rectangle((8, 2), 1, 1, linewidth=1, edgecolor='b', facecolor='none')

# Add NAND gates to the plot
ax.add_patch(nand1)
ax.add_patch(nand2)
ax.add_patch(nand3)
ax.add_patch(nand4)
ax.add_patch(nand5)

# Add text labels for NAND gates
ax.text(0.5, 3.5, 'NAND', fontsize=12, ha='center')
ax.text(0.5, 1.5, 'NAND', fontsize=12, ha='center')
ax.text(3.5, 2.5, 'NAND', fontsize=12, ha='center')
ax.text(6.5, 2.5, 'NAND', fontsize=12, ha='center')
ax.text(8.5, 2.5, 'NAND', fontsize=12, ha='center')

# Draw lines to connect gates
plt.plot([1, 2], [3.5, 2.5], color='b')
plt.plot([1, 2], [1.5, 2.5], color='b')
plt.plot([4, 5], [2.5, 2.5], color='b')
plt.plot([7, 8], [2.5, 2.5], color='b')

# Add input and output labels
ax.text(-0.5, 3.5, 'A', fontsize=14, ha='right')
ax.text(-0.5, 1.5, 'B', fontsize=14, ha='right')
ax.text(9.5, 2.5, 'XOR Out', fontsize=14, ha='left')

# Set axis properties
ax.set_xlim(-1, 10)
ax.set_ylim(0, 5)
ax.axis('off')

# Show the circuit diagram
plt.show()
