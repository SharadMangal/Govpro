import re

with open('lib/features/analytics/analytics_screen.dart', 'r') as f:
    content = f.read()

# 1. Fix _AnimatedLineChartCardState closing brace
content = content.replace("    );\n  Widget _buildAuthorityPerformanceGraph", "    );\n  }\n}\n\n  Widget _buildAuthorityPerformanceGraph")

# 2. Move _buildAuthorityPerformanceGraph and _buildAuthorityMonthlyTrendGraph to inside AnalyticsScreen
# Find the start of _buildAuthorityPerformanceGraph
start_idx = content.find("  Widget _buildAuthorityPerformanceGraph")
end_idx = content.find("class _AuthChartData")
if start_idx != -1 and end_idx != -1:
    graphs_code = content[start_idx:end_idx].strip()
    
    # Remove the graphs from the end of the file
    content = content[:start_idx] + content[end_idx:]
    
    # Insert graphs_code before `class _AnimatedBarChartCard`
    insert_idx = content.find("class _AnimatedBarChartCard extends StatefulWidget {")
    content = content[:insert_idx] + graphs_code + "\n\n" + content[insert_idx:]

# 3. Fix _isAnimationFinished in AnalyticsScreen
content = content.replace("sectionsSpace: _isAnimationFinished ? 3 : 0", "sectionsSpace: 3")
content = content.replace("value: _isAnimationFinished ? (completed == 0 ? 0.001 : completed.toDouble()) : 0.001", "value: completed == 0 ? 0.001 : completed.toDouble()")
content = content.replace("value: _isAnimationFinished ? (inProgress == 0 ? 0.001 : inProgress.toDouble()) : 0.001", "value: inProgress == 0 ? 0.001 : inProgress.toDouble()")
content = content.replace("value: _isAnimationFinished ? (delayed == 0 ? 0.001 : delayed.toDouble()) : 0.001", "value: delayed == 0 ? 0.001 : delayed.toDouble()")
content = content.replace("swapAnimationDuration: _isAnimationFinished \n                          ? const Duration(milliseconds: 150)\n                          : const Duration(milliseconds: 1000)", "swapAnimationDuration: const Duration(milliseconds: 1000)")

content = content.replace("toY: _isAnimationFinished ? score : 0.0", "toY: score")
content = content.replace("duration: _isAnimationFinished ? const Duration(milliseconds: 150) : const Duration(milliseconds: 1000)", "duration: const Duration(milliseconds: 1000)")
content = content.replace("swapAnimationDuration: _isAnimationFinished ? const Duration(milliseconds: 150) : const Duration(milliseconds: 1000)", "swapAnimationDuration: const Duration(milliseconds: 1000)")

content = content.replace("_isAnimationFinished ? count.toDouble() : 0.0", "count.toDouble()")

with open('lib/features/analytics/analytics_screen.dart', 'w') as f:
    f.write(content)
