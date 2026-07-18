import re

with open('lib/features/analytics/analytics_screen.dart', 'r') as f:
    content = f.read()

# 1. Replace the call
content = content.replace(
    "_buildAuthorityMonthlyTrendGraph(context, projects, authoritiesAsync),",
    "_AuthorityMonthlyTrendCard(projects: projects, authoritiesAsync: authoritiesAsync),"
)

# 2. Extract and remove _buildAuthorityMonthlyTrendGraph
start_idx = content.find("  Widget _buildAuthorityMonthlyTrendGraph(")
end_idx = content.find("  }", start_idx) + 3 # The method ends around 542

# Since we don't know exact end, let's just find the exact text using regex or string find
# The method ends right before `class _AnimatedBarChartCard extends StatefulWidget {`
end_idx = content.find("class _AnimatedBarChartCard extends StatefulWidget {")
if start_idx != -1 and end_idx != -1:
    content = content[:start_idx] + content[end_idx:]

new_class = """
class _AuthorityMonthlyTrendCard extends StatefulWidget {
  final List<Project> projects;
  final AsyncValue<List<dynamic>> authoritiesAsync;

  const _AuthorityMonthlyTrendCard({
    required this.projects,
    required this.authoritiesAsync,
  });

  @override
  State<_AuthorityMonthlyTrendCard> createState() => _AuthorityMonthlyTrendCardState();
}

class _AuthorityMonthlyTrendCardState extends State<_AuthorityMonthlyTrendCard> {
  final Set<String> _hiddenAuthorities = {};

  @override
  Widget build(BuildContext context) {
    return widget.authoritiesAsync.maybeWhen(
      data: (authorities) {
        final Map<String, String> authNameMap = {for (var a in authorities) a.id: a.name};
        final Map<String, Map<int, int>> authMonthCounts = {};
        
        for (var project in widget.projects) {
          if (project.authorityId == null) continue;
          final month = project.endDate.month;
          
          authMonthCounts.putIfAbsent(project.authorityId!, () => {});
          authMonthCounts[project.authorityId!]![month] = (authMonthCounts[project.authorityId!]![month] ?? 0) + 1;
        }

        if (authMonthCounts.isEmpty) return const SizedBox();

        final List<Color> lineColors = [
          const Color(0xFF00796B),
          const Color(0xFFD32F2F),
          const Color(0xFFF5A623),
          const Color(0xFF0052CC),
        ];

        final allKeys = authMonthCounts.keys.toList();
        
        final lineBarsData = authMonthCounts.entries
            .where((entry) => !_hiddenAuthorities.contains(entry.key))
            .map((entry) {
          final authIndex = allKeys.indexOf(entry.key);
          final color = lineColors[authIndex % lineColors.length];
          final monthMap = entry.value;
          
          final spots = List.generate(12, (index) {
            final count = monthMap[index + 1] ?? 0;
            return FlSpot((index + 1).toDouble(), count.toDouble());
          });
          
          return LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          );
        }).toList();

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppTheme.cardBorder, width: 1.0),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COMPLETION TREND BY AUTHORITY',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                              if (value % 1 == 0 && value.toInt() > 0 && value.toInt() <= 12) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(months[value.toInt()], style: const TextStyle(fontSize: 10)),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: lineBarsData,
                    ),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: authMonthCounts.entries.map((entry) {
                    final authIndex = allKeys.indexOf(entry.key);
                    final isHidden = _hiddenAuthorities.contains(entry.key);
                    final color = isHidden ? Colors.grey.withOpacity(0.3) : lineColors[authIndex % lineColors.length];
                    final name = authNameMap[entry.key] ?? 'Unknown';
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isHidden) {
                            _hiddenAuthorities.remove(entry.key);
                          } else {
                            _hiddenAuthorities.add(entry.key);
                          }
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(name, style: TextStyle(
                            fontSize: 12, 
                            color: isHidden ? Colors.grey : Colors.black87,
                            decoration: isHidden ? TextDecoration.lineThrough : null,
                          )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox(),
    );
  }
}
"""

content += "\n" + new_class

with open('lib/features/analytics/analytics_screen.dart', 'w') as f:
    f.write(content)
