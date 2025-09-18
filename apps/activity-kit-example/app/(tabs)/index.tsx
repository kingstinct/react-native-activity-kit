import { ActivityKit, AlarmKit } from '@kingstinct/react-native-activity-kit' // Importing the ActivityKit module'
import { Image } from 'expo-image'
import * as Notifications from 'expo-notifications'
import { useState } from 'react'
import { Button, Platform, StyleSheet } from 'react-native'
import { HelloWave } from '@/components/HelloWave'
import ParallaxScrollView from '@/components/ParallaxScrollView'
import { ThemedText } from '@/components/ThemedText'
import { ThemedView } from '@/components/ThemedView'

export default function HomeScreen() {
  const [latestActivityId, setLatestActivityId] = useState<string | null>(null)
  return (
    <ParallaxScrollView
      headerBackgroundColor={{ light: '#A1CEDC', dark: '#1D3D47' }}
      headerImage={
        <Image
          source={require('@/assets/images/partial-react-logo.png')}
          style={styles.reactLogo}
        />
      }
    >
      <Button
        onPress={() =>
          setLatestActivityId(
            ActivityKit.startActivity(
              { name: 'Test Activity' },
              {
                name: 'Robert',
                startedTimerAt: new Date('2025-08-06').valueOf(),
              },
              {
                relevanceScore: 1,
                staleDate: new Date('2025-08-07'),
              },
            ).id,
          )
        }
        title="Start Activity"
      ></Button>
      <Button
        onPress={() =>
          Notifications.requestPermissionsAsync({
            ios: {
              allowAlert: true,
              allowBadge: true,
              allowSound: true,
            },
          })
        }
        title="Push permissions"
      ></Button>
      <Button
        onPress={() => AlarmKit.requestAuthorization()}
        title="AlarmKit permissions"
      ></Button>

      <Button
        onPress={() => {
          const countdownDurationInSeconds = 10
          AlarmKit.createCountdown({
            tintColor: { red: 255, green: 0, blue: 0, alpha: 0.5 },
            alert: {
              title: 'Pomodoro focus time over!',
              stopButton: {
                text: 'Ok, cool!',
                systemImageName: 'stop.fill',
                textColor: { red: 0, green: 255, blue: 0 },
              },
            },
            countdown: {
              title: 'Pomodoro focus time!',
            },
            preAlert: countdownDurationInSeconds,
            metadata: {
              timerFiringAt: Date.now() + countdownDurationInSeconds * 1000,
            },
          })
        }}
        title="Start countdown"
      ></Button>

      {latestActivityId ? (
        <Button
          onPress={() => {
            const activity = ActivityKit.getActivityById(latestActivityId)
            if (activity) {
              activity.update(
                { name: 'Updated Activity' },
                {
                  alertConfiguration: {
                    title: 'Activity Updated',
                    body: 'The activity has been updated successfully.',
                  },
                  timestamp: new Date(),
                  mergeWithPreviousState: true,
                },
              )
              console.log('Activity updated:', activity)
            } else {
              console.warn('Activity not found')
            }
          }}
          title="Update Activity"
        ></Button>
      ) : null}
      <Button
        onPress={() =>
          console.log(
            ActivityKit.getAllActivities().map((activity) => ({
              pushToken: activity.pushToken,
              id: activity.id,
              state: activity.state,
              attributes: activity.attributes,
              activityState: activity.activityState,
              staleDate: activity.staleDate,
              relevanceScore: activity.relevanceScore,
            })),
          )
        }
        title="List Activities"
      />
      {/* <Button onPress={() => ActivityKit.updateActivity('activity-id', { name: 'Updated Activity' })} title='Update Activity' />
      <Button onPress={() => ActivityKit.endActivity('activity-id')} title='End Activity' /> */}
      <ThemedView style={styles.titleContainer}>
        <ThemedText type="title">Welcome!</ThemedText>
        <HelloWave />
      </ThemedView>
      <ThemedView style={styles.stepContainer}>
        <ThemedText type="subtitle">Step 1: Try it</ThemedText>
        <ThemedText>
          Edit{' '}
          <ThemedText type="defaultSemiBold">app/(tabs)/index.tsx</ThemedText>{' '}
          to see changes. Press{' '}
          <ThemedText type="defaultSemiBold">
            {Platform.select({
              ios: 'cmd + d',
              android: 'cmd + m',
              web: 'F12',
            })}
          </ThemedText>{' '}
          to open developer tools.
        </ThemedText>
      </ThemedView>
      <ThemedView style={styles.stepContainer}>
        <ThemedText type="subtitle">Step 2: Explore</ThemedText>
        <ThemedText>
          {`Tap the Explore tab to learn more about what's included in this starter app.`}
        </ThemedText>
      </ThemedView>
      <ThemedView style={styles.stepContainer}>
        <ThemedText type="subtitle">Step 3: Get a fresh start</ThemedText>
        <ThemedText>
          {`When you're ready, run `}
          <ThemedText type="defaultSemiBold">npm run reset-project</ThemedText>{' '}
          to get a fresh <ThemedText type="defaultSemiBold">app</ThemedText>{' '}
          directory. This will move the current{' '}
          <ThemedText type="defaultSemiBold">app</ThemedText> to{' '}
          <ThemedText type="defaultSemiBold">app-example</ThemedText>.
        </ThemedText>
      </ThemedView>
    </ParallaxScrollView>
  )
}

const styles = StyleSheet.create({
  titleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  stepContainer: {
    gap: 8,
    marginBottom: 8,
  },
  reactLogo: {
    height: 178,
    width: 290,
    bottom: 0,
    left: 0,
    position: 'absolute',
  },
})
